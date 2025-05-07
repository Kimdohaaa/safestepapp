import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
    clientId: '0i2o3ztm19',
    onAuthFailed: (e) => print("네이버맵 인증오류 : $e"),
  );
}

class NaverMapApp extends StatefulWidget {
  final List<dynamic> patientsList;

  const NaverMapApp({Key? key, required this.patientsList}) : super(key: key);

  @override
  State<NaverMapApp> createState() => _NaverMapAppState();
}

class _NaverMapAppState extends State<NaverMapApp> {
  late NaverMapController _mapController;
  Dio dio = Dio();
  final defaultPosition = NLatLng(37.5665, 126.9780);

  @override
  Widget build(BuildContext context) {
    if (widget.patientsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final firstPatient = widget.patientsList[0];
    final patientLatLng = NLatLng(firstPatient['plat'], firstPatient['plon']);

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(target: patientLatLng, zoom: 15),
        locationButtonEnable: false,
      ),
        onMapReady: (controller) async {
          _mapController = controller;

          List<Future<void>> tasks = [];

          for (var patient in widget.patientsList) {
            int pno = patient['pno'];
            double? lat = patient['plat'];
            double? lon = patient['plon'];
            bool valid = patient['pstate'] ?? true;

            String pname = await findPname(pno);

            if (lat != null && lon != null) {
              final marker = NMarker(
                id: 'patient_$pno',
                position: NLatLng(lat, lon),
                caption: NOverlayCaption(text: pname),
              );
              await _mapController.addOverlay(marker);

              if (!valid) {
                tasks.add(drawRouteForPatient(pno)); // 병렬 작업에 추가
              }
            }
          }

          await Future.wait(tasks); // 모든 경로 그리기 작업 병렬 처리
        }

    );
  }

  Future<String> findPname(int pno) async {
    try {
      final response = await dio.get("http://192.168.40.34:8080/patient/find?pno=$pno");
      return response.data['pname'] ?? 'Unknown';
    } catch (e) {
      print(e);
      return 'Unknown';
    }
  }

  // 각 환자의 이동경로를 선으로 지도 상에 표시
  Future<void> drawRouteForPatient(int pno) async {
    try {
      final response = await dio.get("http://192.168.40.34:8080/location/findroute?pno=$pno");

      print("환자이동경로 확인 ${response.data}");
      if (response.data is List) {
        List<NLatLng> pathPoints = [];

        for (var point in response.data) {
          if (point['plat'] != null && point['plon'] != null) {
            pathPoints.add(NLatLng(point['plat'], point['plon']));
          }
        }

        if (pathPoints.isNotEmpty) {
          // 랜덤 색상 지정 변수 생성
          Color randomColor = getRandomColor();

          final pathOverlay = NPathOverlay(
            id: 'route_$pno',
            coords: pathPoints,
            color: randomColor,
            width: 5,
          );
          await _mapController.addOverlay(pathOverlay);
        }
      }
    } catch (e) {
      print("경로 불러오기 오류: $e");
    }
  }

// 지도 상의 환자경로 색상 랜덤 지정
  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // R
      random.nextInt(256), // G
      random.nextInt(256), // B
      1, // Alpha (불투명도)
    );
  }
}

class GuardianHome extends StatefulWidget {
  const GuardianHome({super.key});

  @override
  State<StatefulWidget> createState() => _GuardianHomeState();
}

class _GuardianHomeState extends State<GuardianHome> {
  Dio dio = Dio();
  int gno = 0;
  List<dynamic> patientsList = [];
  List<int> pnoList = [];

  @override
  void initState() {
    super.initState();
    _initialize();
    findGno();
  }

  void findGno() async {
    try {
      final response = await dio.get("http://192.168.40.34:8080/guardian/findgno");
      if (response.data > 0) {
        setState(() {
          gno = response.data;
        });
        findPatients(gno);
      }
    } catch (e) {
      print("gno 조회 오류: $e");
    }
  }

  void findPatients(int gno) async {
    try {
      final response = await dio.get("http://192.168.40.34:8080/patient/findall?gno=$gno");
      if (response.data != null) {
        setState(() {
          pnoList.clear();
          for (var item in response.data) {
            pnoList.add(item['pno']);
          }
        });
        getLastRoute(pnoList);
      }
    } catch (e) {
      print("환자 목록 조회 오류: $e");
    }
  }

  void getLastRoute(List<int> pnoList) async {
    try {
      final response = await dio.post(
        "http://192.168.40.34:8080/location/lastroute",
        data: pnoList,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.data != null) {
        setState(() {
          patientsList = response.data;
        });
      }
    } catch (e) {
      print("위치 조회 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: patientsList.isEmpty
          ? Center(child: Text("위치를 조회중인 환자가 없습니다"))
          : NaverMapApp(patientsList: patientsList),
    );
  }
}
