import 'dart:async';
import 'dart:developer';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/android_settings.dart' as locator_android; // Alias for background_locator_2's AndroidSettings
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart' as geolocator; // Alias for geolocator
import 'package:geolocator_android/geolocator_android.dart' as geolocator_android; // Alias for geolocator_android's AndroidSettings

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

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart' as locator_android; // Alias for background_locator_2's AndroidSettings
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';

void main() async {
  // 지도 테스트용으로 runApp()
  await _initialize();

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

  // 지도 초기화 끝나고, 백그라운드 위치 추적 시작
  await _initBackgroundLocator();
}

Future<void> _initBackgroundLocator() async {
  // 위치 권한을 먼저 요청
  geolocator.LocationPermission permission = await geolocator.Geolocator.requestPermission();
  if (permission == geolocator.LocationPermission.denied) {
    print("권한없음1");
    throw Exception("위치 권한이 거부되었습니다.");
  } else if (permission == geolocator.LocationPermission.deniedForever) {
    print("권한없음2");
    throw Exception("위치 권한이 영구적으로 거부되었습니다.");
  }

  // 권한이 승인되었을 때 위치 추적 시작
  bool isRunning = await BackgroundLocator.isServiceRunning();
  print("위치추적 서비스 실행 여부: $isRunning");

  if (!isRunning) {
    print("위치추적 서비스 시작 중");
    try {
      print("위치추적 try 문 진입");
      await BackgroundLocator.registerLocationUpdate(
        ( locationDto ) { print(locationDto); } ,
      );
      print("위치추적 서비스가 정상적으로 시작되었습니다.");
    } catch (e) {
      print("위치추적 서비스 시작 실패: $e");
    }
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
