import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

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
  final defaultPosition = NLatLng(37.5665, 126.9780); // 환자 정보가 없을 시 지도 출력 기본 위치

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

          String pname = await findPname(pno);

          if (lat != null && lon != null) {
            final marker = NMarker(
              id: 'patient_$pno',
              position: NLatLng(lat, lon),
              caption: NOverlayCaption(text: pname),
            );
            await _mapController.addOverlay(marker);

            // 서버에서 환자의 안전위치를 가져와서 현재 위치와 비교
            final safeRes = await dio.get("http://192.168.40.34:8080/patient/find?pno=$pno");
            final safeData = safeRes.data;

            double? safeLat = safeData['plat'];
            double? safeLon = safeData['plon'];

            if (safeLat != null && safeLon != null) {
              // 안전위치로 부터 150m 이내인지 검증
              double distance = calculateDistance(lat, lon, safeLat, safeLon);

              if (distance > 150) {
                // 안전 위치로부터 150m 이상 떨어져 있으면 이동경로 지도상에 출력
                tasks.add(drawRouteForPatient(pno));
              }
            }
          }
        }

        await Future.wait(tasks);
      },
    );
  }

  // [#] 각 환자의 이름 조회
  Future<String> findPname(int pno) async {
    try {
      final response = await dio.get("http://192.168.40.34:8080/patient/find?pno=$pno");
      return response.data['pname'] ?? 'Unknown';
    } catch (e) {
      print(e);
      return 'Unknown';
    }
  }

  // [#] 지도 상 환자의 이동경로 출력 함수(환자가 안전위치로부터 150m 이상 떨어졌을 때만 실행)
  Future<void> drawRouteForPatient(int pno) async {
    try {
      final response = await dio.get("http://192.168.40.34:8080/location/findroute?pno=$pno");

      if (response.data is List) {
        List<NLatLng> pathPoints = [];

        for (var point in response.data) {
          if (point['plat'] != null && point['plon'] != null) {
            pathPoints.add(NLatLng(point['plat'], point['plon']));
          }
        }

        if (pathPoints.isNotEmpty) {
          // 이동경로 색상 랜덤 지정
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

  // [*] 이동경로 색상 랜덤 지정
  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  // [*] 안전위치와 환자의 현재 위치 계산 (하버사인 공식)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000;
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double degree) => degree * pi / 180;
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

  // [#] 현재 로그인 중인 gno 가져오기
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

  // [#] 로그인 중인 gno 에 해당하는 모든 환자 정보 가져오기
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

  // [#] 각 환자의 마지막 위치 조회
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
      // 해당 보호자가 관리 중인 환자가 없으면 안내문구 출력
          ? Center(child: Text("위치를 조회중인 환자가 없습니다"))
      // 있으면 지도 출력
          : NaverMapApp(patientsList: patientsList),
    );
  }
}
