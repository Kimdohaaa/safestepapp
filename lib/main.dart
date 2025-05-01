import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart' as geolocator; // Alias for geolocator
import 'package:geolocator_android/geolocator_android.dart' as geolocator_android; // Alias for geolocator_android's AndroidSettings

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'package:safestepapp/main/home.dart';
import 'package:safestepapp/map/locatioincallbackhandler.dart';
import 'package:safestepapp/map/map.dart';
import 'package:safestepapp/user/guardian/findpatient.dart';
import 'package:safestepapp/user/guardian/guardian.dart';
import 'package:safestepapp/user/guardian/guardianhome.dart';
import 'package:safestepapp/user/guardian/guardianinfo.dart';
import 'package:safestepapp/user/guardian/guardianmain.dart';
import 'package:safestepapp/user/guardian/patient/additionpatient.dart';
import 'package:safestepapp/user/guardian/patient/changelocation.dart';
import 'package:safestepapp/user/guardian/patient/enrolllocation.dart';
import 'package:safestepapp/user/guardian/patient/enrollpatient.dart';
import 'package:safestepapp/user/guardian/patient/updatepatient.dart';
import 'package:safestepapp/user/guardian/resignguardian.dart';
import 'package:safestepapp/user/guardian/signup.dart';
import 'package:safestepapp/user/patient/authentication.dart';
import 'package:safestepapp/user/patient/patientsetting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() async {
  // 지도 테스트용으로 runApp()
  await _initialize();

  await LocationTrackingService().start();
  // 실제 사용할 메인 위젯
  runApp(const MyApp());

}

// 지도 초기화하기
Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
      clientId: '0i2o3ztm19', // 클라이언트 ID 설정
      onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed")
  );
}

// 위치 추적 서비스 클래스
class LocationTrackingService {
  final Dio dio = Dio();
  double? plon;
  double? plat;

  List<dynamic> routeList = [];

  // 위치 추적 시작
  Future<void> start() async {


    // 위치 수신 이벤트 처리
    bg.BackgroundGeolocation.onLocation((bg.Location location) async {

      final prefs = await SharedPreferences.getInstance();
      final pno = prefs.getString("pno");
      final isGranted = prefs.getBool("isGranted");
      final findState = prefs.getBool('findState');
      print("1. 위치조회 권환 확인 환자번호 : $pno 권한상태 : $isGranted 와 $findState");

      plat = location.coords.latitude;
      plon = location.coords.longitude;
      print('[location] - 위도: $plat, 경도: $plon');

      try {
        if(pno != null && pno != '' && isGranted == true && findState == true){
          final obj = {
            "plon" : plon,
            "plat" : plat,
            "pno" : pno
          };
          final response = await dio.post("http://192.168.40.34:8080/location/save",data: obj);

          print("안전위치확인 ${response.data}");
          if(response.data == false){
            final findRoute = await dio.get("http://192.168.40.34:8080/location/findroute?pno=$pno");

            if(findRoute.data != null){
              routeList = findRoute.data;
              print(routeList);
            }
          }
        }
        // 위치 정보를 서버로 전송
        // final response = await dio.post(
        //   "http://192.168.0.100:8080/location",  // 여기에 실제 서버 주소 입력
        //   data: {"lat": plat, "lon": plon},
        //   options: Options(connectTimeout: const Duration(seconds: 5)),
        // );

        // 서버 응답 처리 (서버 응답 false일 때 이동경로 요청)
        // if (response.data == false) {
        //   final pathResponse = await dio.get(
        //     "http://192.168.0.100:8080/location/path", // 이동경로 API 엔드포인트
        //     queryParameters: {"patientId": 1}, // 필요 시 수정
        //   );
        //   print("[이동경로 응답] - ${pathResponse.data}");
        // }
      } catch (e) {
        print("[에러] 위치 전송 실패: $e");
      }
    });

    // 상태 변경 시
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
    });

    // 위치 서비스 상태 변경 시
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
    });

    // 설정
    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0,
      stopOnTerminate: false,
      startOnBoot: true,
      debug: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      heartbeatInterval: 60, // 10분마다 heartbeat
    ));

    // 위치 추적 시작
    await bg.BackgroundGeolocation.start();

    // Heartbeat 이벤트 (10분마다 강제 실행하도록 시간 설정하기)
    bg.BackgroundGeolocation.onHeartbeat((bg.HeartbeatEvent event){
      bg.BackgroundGeolocation.getCurrentPosition().then((bg.Location location) async {
        plat = location.coords.latitude;
        plon = location.coords.longitude;

        final prefs = await SharedPreferences.getInstance();
        final pno = prefs.getString("pno");
        final isGranted = prefs.getBool("isGranted");
        final findState = prefs.getBool('findState');
        print("2. 위치조회 권환 확인 환자번호 : $pno 권한상태 : $isGranted 와 $findState");

        print('[Heartbeat 위치조회] - 위도: $plat, 경도: $plon');
        // 서버로 위치 전송 가능
      });
    });
  }
}



// 라우터 클래스
class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/", // 나중에 "/" 로 바꾸기
      routes: {
        "/" : (context) => Home(),
        "/map" : (context) => NaverMapApp(),
        "/guardian" : (context) => Guardian(),
        "/patientsetting" : (context) => PatientSetting(),
        "/signup" : (context) => Signup(),
        "/guardianmain" : (context) => GuardianMain(),
        "/enrollpatient" : (context) => EnrollPatient(),
        "/guardianinfo" : (context) => GuardianInfo(),
        "/findpatient" : (context) => FindPatient(),
        "/additionpatient" : (context) => AdditionPatient(),
        "/updatepatient" : (context) => UpdatePatient(),
        "/resignguardian" : (context) => ResignGuardian(),
        "/guardianhome" : (context) => GuardianHome(),
        "/enrollLocation" : (context) => EnrollLocation(),
        "/changeLocation" : (context) => ChangeLocation(),
        "/authentication" : (context) => Authentication(),
      },
    );
  }
}

// 네이버 지도
class NaverMapApp extends StatelessWidget {
  const NaverMapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<geolocator.Position>( // geolocator로 위치를 가져옴
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

  // 위치를 가져오는 함수 (geolocator 사용)
  Future<geolocator.Position> _getCurrentLocation() async {
    geolocator.LocationPermission permission = await geolocator.Geolocator.requestPermission();
    if (permission == geolocator.LocationPermission.denied) {
      throw Exception("위치 권한이 거부되었습니다.");
    } else if (permission == geolocator.LocationPermission.deniedForever) {
      throw Exception("위치 권한이 영구적으로 거부되었습니다.");
    }
    return await geolocator.Geolocator.getCurrentPosition();
  }
}
