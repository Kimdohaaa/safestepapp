// 생략된 import 구문
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
  final List<dynamic> patientsList; // 환자 정보 리스트
  final String? searchTarget; // 검색할 pno

  const NaverMapApp({Key? key, required this.patientsList, this.searchTarget}) : super(key: key);

  @override
  State<NaverMapApp> createState() => _NaverMapAppState();
}

class _NaverMapAppState extends State<NaverMapApp> {
  NaverMapController? _mapController; // Naver Map 제어 컨트롤러
  Dio dio = Dio();
  final defaultPosition = NLatLng(37.5665, 126.9780); // 환자 정보가 없을 시 지도 출력 기본 위치

  @override
  void didUpdateWidget(covariant NaverMapApp oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 만약 searchTarget이 변경됐고 지도 컨트롤러가 준비되어 있으면 위치 이동
    if (widget.searchTarget != null &&
        widget.searchTarget != oldWidget.searchTarget &&
        _mapController != null) {
      // searchTarget 과 일치하는 환자 정보 조회
      final matched = widget.patientsList.firstWhere(
            (patient) => patient['pno'].toString() == widget.searchTarget,
        orElse: () => null,
      );

      // 일치하는 환자가 있으면 지도를 해당 환자의 현재 위치로 이동
      if (matched != null) {
        double lat = matched['plat'];
        double lon = matched['plon'];

        _mapController!.updateCamera(
          NCameraUpdate.withParams(
            target: NLatLng(lat, lon),
            zoom: 16,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 환자리스트가 아직 조회되지 않았으면 로딩 출력
    if (widget.patientsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 조회된 환자 리스트 중 첫번째 환자의 현재 위치를 초기 위치로 지정
    final firstPatient = widget.patientsList[0];
    final patientLatLng = NLatLng(firstPatient['plat'], firstPatient['plon']);

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(target: patientLatLng, zoom: 15),
        locationButtonEnable: false, // 현재 휴대폰의 위치 조회 비활성화
      ),
      onMapReady: (controller) async {
        _mapController = controller; // 지도 컨트롤러 초기화
        List<Future<void>> tasks = []; // 비동기 작업 목록 리스트

        for (var patient in widget.patientsList) {
          int pno = patient['pno'];
          double? lat = patient['plat'];
          double? lon = patient['plon'];

          String pname = await findPname(pno); // 환자 이름 조회

          // 위도와 경도가 존재하면 마커 추가
          if (lat != null && lon != null) {
            final marker = NMarker(
              id: 'patient_$pno',
              position: NLatLng(lat, lon),
              caption: NOverlayCaption(text: pname),
            );
            await _mapController!.addOverlay(marker); // 지도에 마커 추가

            // searchTarget 이 현재 환자번호와 일치하면 화면의 지도를 해당 위치 기준으로 출력
            if (widget.searchTarget != null && widget.searchTarget == pno.toString()) {
              await _mapController!.updateCamera(
                NCameraUpdate.withParams(
                  target: NLatLng(lat, lon),
                  zoom: 16,
                ),
              );
            }

            // 환자의 안전위치 조회
            final safeRes = await dio.get("http://192.168.40.34:8080/patient/find?pno=$pno");
            final safeData = safeRes.data;

            double? safeLat = safeData['plat'];
            double? safeLon = safeData['plon'];

            // 안전 위치가 존재하면 현재 위치와 안전 위치의 거리 계산
            if (safeLat != null && safeLon != null) {
              double distance = calculateDistance(lat, lon, safeLat, safeLon);

              // 안전 위치와 현재 위치가 150m 이상 차이날 경우 이동경로 출력
              if (distance > 150) {
                tasks.add(drawRouteForPatient(pno));
              }
            }
          }
        }

        await Future.wait(tasks); // 비동기 작업 완료 시 까지 대기
      },
    );
  }

  // [#] 환자의 이름 조회
  Future<String> findPname(int pno) async {
    try {
      final response = await dio.get("http://192.168.40.34:8080/patient/find?pno=$pno");
      return response.data['pname'] ?? 'Unknown';
    } catch (e) {
      print(e);
      return 'Unknown';
    }
  }

  // [#] 환자의 이동 경로 출력
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
          // 이동 경로 색상 랜덤 지정
          Color randomColor = getRandomColor();

          final pathOverlay = NPathOverlay(
            id: 'route_$pno',
            coords: pathPoints,
            color: randomColor,
            width: 5,
          );
          await _mapController!.addOverlay(pathOverlay);
        }
      }
    } catch (e) {
      print("경로 불러오기 오류: $e");
    }
  }

  // [*] 이동 경로 색상 랜덤 지정
  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  // [*] 안전 위치와 현재 위치 거리 계산
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
  TextEditingController pnoController = TextEditingController();
  String? searchTarget;
  List<dynamic> patientsList = [];
  List<int> pnoList = [];

  @override
  void initState() {
    super.initState();
    _initialize();
    findGno();
  }

  // [#] 현재 로그인 중인 gno 조회
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

  // [#] 해당 gno 가 관리 중인 환자 전체 조회 
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

  // [#] 해당 gno 가 관리 중인 환자들의 현재 위치 조회
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

  // [#] 환자번호를 통해 환자의 현재 위치 검색
  void onSearchPressed() {
    String inputPno = pnoController.text.trim();
    if (inputPno.isEmpty) return;

    final match = patientsList.firstWhere(
          (patient) => patient['pno'].toString() == inputPno,
      orElse: () => null,
    );

    if (match != null) {
      setState(() {
        searchTarget = inputPno;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("환자정보가 존재하지 않습니다")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pnoController,
                    decoration: const InputDecoration(
                      hintText: '검색할 환자번호',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onSearchPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    minimumSize: const Size(130, 50),
                  ),
                  child: const Text(
                    "검색",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: patientsList.isEmpty
                ? const Center(child: Text("위치를 조회중인 환자가 없습니다"))
                : NaverMapApp(
              patientsList: patientsList,
              searchTarget: searchTarget,
            ),
          ),
        ],
      ),
    );
  }
}
