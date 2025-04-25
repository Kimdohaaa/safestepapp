import 'dart:async';
import 'dart:developer';
import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:safestepapp/main/home.dart';
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
          // "/findlocation" : (context) => FindLocation()
        }
    );
  }
}


// 네이버 지도
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
