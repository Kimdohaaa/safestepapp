import 'dart:async';
import 'dart:developer';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:safestepapp/main/home.dart';
import 'package:safestepapp/map/map.dart';
import 'package:safestepapp/user/guardian.dart';
import 'package:safestepapp/user/patient.dart';

void main() async {
  // 지도 테스트용으로 runApp()
  await _initialize();
  //runApp(const NaverMapApp());

  // 실제 사용할 메인 위젯
  runApp(const MyApp());
}

// 지도 초기화하기
Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
      clientId: '0i2o3ztm19',     // 클라이언트 ID 설정
      onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed")
  );
}



// 라우터 클래스
class MyApp extends StatelessWidget{

  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     // home: const NaverMapApp(),
      initialRoute: "/",
      routes: {
        "/" : (context) => Home(),
        "/map" : (context) => NaverMapApp(),
        "/guardian" : (context) => Guardian(),
        "/patient" : (context) => Patient()
      }
    );
  }
}



class NaverMapApp extends StatelessWidget {
  const NaverMapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Position>(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userPos = snapshot.data!;
          final userLatLng = NLatLng(userPos.latitude, userPos.longitude);

          return NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: userLatLng,
                zoom: 15,
              ),
              locationButtonEnable: true,
            ),
            onMapReady: (controller) {
              log("onMapReady", name: "onMapReady");

              final marker = NMarker(
                id: 'current_location',
                position: userLatLng,
              );

              controller.addOverlay(marker);
            },
          );
        },
      ),
    );
  }

  // 위치를 가져오는 함수
  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception("위치 권한이 거부되었습니다.");
    } else if (permission == LocationPermission.deniedForever) {
      throw Exception("위치 권한이 영구적으로 거부되었습니다.");
    }
    return await Geolocator.getCurrentPosition();
  }
}

//
// // 지도 초기화하기
// Future<void> _initialize() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NaverMapSdk.instance.initialize(
//       clientId: '0i2o3ztm19',     // 클라이언트 ID 설정
//       onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed")
//   );
// }
//
// class NaverMapApp extends StatelessWidget {
//   const NaverMapApp({Key? key});
//
//   @override
//   Widget build(BuildContext context) {
//     // NaverMapController 객체의 비동기 작업 완료를 나타내는 Completer 생성
//     final Completer<NaverMapController> mapControllerCompleter = Completer();
//
//     return MaterialApp(
//       home: Scaffold(
//         body: NaverMap(
//           options: const NaverMapViewOptions(
//             indoorEnable: true,             // 실내 맵 사용 가능 여부 설정
//             locationButtonEnable: false,    // 위치 버튼 표시 여부 설정
//             consumeSymbolTapEvents: false,  // 심볼 탭 이벤트 소비 여부 설정
//           ),
//           onMapReady: (controller) async {                // 지도 준비 완료 시 호출되는 콜백 함수
//             mapControllerCompleter.complete(controller);  // Completer에 지도 컨트롤러 완료 신호 전송
//             log("onMapReady", name: "onMapReady");
//           },
//         ),
//       ),
//     );
//   }
// }
