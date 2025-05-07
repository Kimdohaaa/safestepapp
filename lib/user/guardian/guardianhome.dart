// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter_naver_map/flutter_naver_map.dart';
// import 'package:geolocator/geolocator.dart';
//
// // 지도 초기화
// Future<void> _initialize() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NaverMapSdk.instance.initialize(
//     clientId: '0i2o3ztm19', // 네이버 클라이언트 ID
//     onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed"),
//   );
// }
//
// // 지도 화면 (환자 위치 마커 포함)
// class NaverMapApp extends StatefulWidget {
//   final List<dynamic> patientsList;
//
//   const NaverMapApp({Key? key, required this.patientsList}) : super(key: key);
//
//   @override
//   State<NaverMapApp> createState() => _NaverMapAppState();
// }
//
// class _NaverMapAppState extends State<NaverMapApp> {
//   late NaverMapController _mapController;
//
//   Dio dio = Dio();
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Position>(
//       future: _getCurrentLocation(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         final userLatLng = NLatLng(snapshot.data!.latitude, snapshot.data!.longitude);
//
//         return NaverMap(
//           options: NaverMapViewOptions(
//             initialCameraPosition: NCameraPosition(
//               target: userLatLng,
//               zoom: 15,
//             ),
//             locationButtonEnable: true,
//           ),
//           onMapReady: (controller) async {
//             _mapController = controller;
//
//             // 현재 위치 마커
//             final currentMarker = NMarker(
//               id: 'current_location',
//               position: userLatLng,
//             );
//             await _mapController.addOverlay(currentMarker);
//
//             // 환자 위치 마커들
//             for (var patient in widget.patientsList) {
//               String pname = await findPname(patient['pno']);
//               if (patient['plat'] != null && patient['plon'] != null) {
//                 final marker = NMarker(
//                   id: 'patient_${patient['pno']}',
//                   position: NLatLng(patient['plat'], patient['plon']),
//                   caption: NOverlayCaption(text: pname), // 환자 이름으로 표시
//                 );
//                 await _mapController.addOverlay(marker);
//               }
//             }
//           },
//         );
//       },
//     );
//   }
//
//   // 위치 권한 요청 및 현재 위치 조회
//   Future<Position> _getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       throw Exception("위치 권한이 거부되었습니다.");
//     } else if (permission == LocationPermission.deniedForever) {
//       throw Exception("위치 권한이 영구적으로 거부되었습니다.");
//     }
//     return await Geolocator.getCurrentPosition();
//   }
//
//   // 최신위치를 조회할 pno 에 해당하는 pname 조회
//   Future<String> findPname(int pno) async {
//     try{
//       final response = await dio.get("http://192.168.40.34:8080/patient/find?pno=$pno");
//
//       print("조회한 환자명 : ${response.data['pname']}");
//       return response.data['pname'] ?? 'Unknown';  // null 방지
//       return response.data['pname'];
//     }catch(e){
//       print(e);
//       return 'Unknown';  // null 방지
//     }
//   }
//
// }
//
// // 보호자 메인 페이지
// class GuardianHome extends StatefulWidget {
//   const GuardianHome({super.key});
//
//   @override
//   State<StatefulWidget> createState() {
//     return _GuardianHomeState();
//   }
// }
//
// class _GuardianHomeState extends State<GuardianHome> {
//   Dio dio = Dio();
//
//   int gno = 0;
//   List<dynamic> patientsList = [];
//   List<int> pnoList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize(); // 네이버맵 초기화
//     findGno();     // 보호자 번호 조회
//   }
//
//   // 로그인된 보호자의 gno 조회
//   void findGno() async {
//     try {
//       final response = await dio.get("http://192.168.40.34:8080/guardian/findgno");
//
//       print("gno 응답: ${response.data}");
//       if (response.data > 0) {
//         setState(() {
//           gno = response.data;
//         });
//         findPatients(gno);
//       }
//     } catch (e) {
//       print("gno 조회 오류: $e");
//     }
//   }
//
//   // 보호자가 등록한 환자 목록 조회
//   void findPatients(int gno) async {
//     print("환자정보 조회 시작");
//     try {
//       final response = await dio.get("http://192.168.40.34:8080/patient/findall?gno=$gno");
//
//       if (response.data != null) {
//         print("환자 목록: ${response.data}");
//
//         setState(() {
//           pnoList.clear();
//           for (var item in response.data) {
//             pnoList.add(item['pno']);
//           }
//           print("관리중인 환자번호: $pnoList");
//         });
//
//         getLastRoute(pnoList);
//       }
//     } catch (e) {
//       print("환자 목록 조회 오류: $e");
//     }
//   }
//
//   // 환자의 최신 위치 조회
//   void getLastRoute(List<int> pnoList) async {
//     print("마지막 위치 조회 시작");
//     try {
//       final response = await dio.post(
//         "http://192.168.40.34:8080/location/lastroute",
//         data: pnoList,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//           },
//         ),
//       );
//
//       print("최종위치 반환값: ${response.data}");
//       if (response.data != null) {
//         setState(() {
//           patientsList = response.data;
//           print("환자의 최신 위치정보: ${patientsList.toString()}");
//         });
//       }
//     } catch (e) {
//       print("위치 조회 오류: $e");
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: NaverMapApp(patientsList: patientsList), // 환자 위치 마커 포함 지도
//     );
//   }
// }


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

// 지도 초기화
Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
    clientId: '0i2o3ztm19', // 네이버 클라이언트 ID
    onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed"),
  );
  print("초기화 완료");
}

// 지도 화면 (환자 위치 마커 포함)
class NaverMapApp extends StatefulWidget {
  final List<dynamic> patientsList;

  const NaverMapApp({Key? key, required this.patientsList}) : super(key: key);

  @override
  State<NaverMapApp> createState() => _NaverMapAppState();
}

class _NaverMapAppState extends State<NaverMapApp> {
  late NaverMapController _mapController;

  Dio dio = Dio();

  final defaultPosition = NLatLng(37.5665, 126.9780); // 디폴트 좌표

  @override
  Widget build(BuildContext context) {
    if (widget.patientsList.isEmpty) {
      return const Center(child: CircularProgressIndicator()); // 환자 리스트가 비어있을 경우 로딩
    }

    final firstPatient = widget.patientsList[0];
    final patientLatLng = NLatLng(firstPatient['plat'], firstPatient['plon']); // 첫 번째 환자 위치

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: patientLatLng,
          zoom: 15,
        ),
        locationButtonEnable: false, // 위치 버튼 비활성화
      ),
      onMapReady: (controller) async {
        _mapController = controller;

        // 환자 위치 마커들
        for (var patient in widget.patientsList) {
          String pname = await findPname(patient['pno']);
          if (patient['plat'] != null && patient['plon'] != null) {
            final marker = NMarker(
              id: 'patient_${patient['pno']}',
              position: NLatLng(patient['plat'], patient['plon']),
              caption: NOverlayCaption(text: pname), // 환자 이름으로 표시
            );
            await _mapController.addOverlay(marker);
          }
        }
      },
    );
  }

  // 최신위치를 조회할 pno에 해당하는 pname 조회
  Future<String> findPname(int pno) async {
    try {
      final response = await dio.get("http://192.168.40.34:8080/patient/find?pno=$pno");
      return response.data['pname'] ?? 'Unknown';  // null 방지
    } catch (e) {
      print(e);
      return 'Unknown';  // null 방지
    }
  }
}

// 보호자 메인 페이지
class GuardianHome extends StatefulWidget {
  const GuardianHome({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GuardianHomeState();
  }
}

class _GuardianHomeState extends State<GuardianHome> {
  Dio dio = Dio();

  int gno = 0;
  List<dynamic> patientsList = [];
  List<int> pnoList = [];

  @override
  void initState() {
    super.initState();
    _initialize(); // 네이버맵 초기화
    findGno();     // 보호자 번호 조회
  }

  // 로그인된 보호자의 gno 조회
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

  // 보호자가 등록한 환자 목록 조회
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

  // 환자의 최신 위치 조회
  void getLastRoute(List<int> pnoList) async {
    try {
      final response = await dio.post(
        "http://192.168.40.34:8080/location/lastroute",
        data: pnoList,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
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
          ? Center(child: Text("위치를 조회중인 환자가 없습니다")) // 환자 위치 정보가 없으면 문구 출력
          : NaverMapApp(patientsList: patientsList), // 환자 위치 마커 포함 지도
    );
  }
}
