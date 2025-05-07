import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart' as geolocator; // Alias for geolocator
// Alias for geolocator_android's AndroidSettings

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:safestepapp/main/home.dart';
import 'package:safestepapp/user/guardian/findpatient.dart';
import 'package:safestepapp/user/guardian/guardian.dart';
import 'package:safestepapp/user/guardian/guardianhome.dart';
import 'package:safestepapp/user/guardian/guardianinfo.dart';
import 'package:safestepapp/user/guardian/guardianmain.dart';
import 'package:safestepapp/user/guardian/patient/additionlocation.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await _initialize(); // NaverMap
  await _getFcmTokenAndSend(); // FCM 토큰 전송
  // 실제 사용할 메인 위젯
  runApp(const MyApp());

  // 위치 추적은 앱이 완전히 실행된 후 시작
  // await LocationTrackingService().start();

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

  // 중복 방지용
  double? _prevLat;
  double? _prevLon;

  List<dynamic> routeList = [];

  // 위치 추적 시작
  Future<void> start() async {


    // 위치 수신 이벤트 처리
    // bg.BackgroundGeolocation.onLocation((bg.Location location) async {
    // });



    // 위치 추적 시작
    await bg.BackgroundGeolocation.start();

    // Heartbeat 이벤트
    bg.BackgroundGeolocation.onHeartbeat((bg.HeartbeatEvent event){
      bg.BackgroundGeolocation.getCurrentPosition().then((bg.Location location) async {

        // [1] 권한 조회
        print(">>>>>>>>>>>>>>>>권한조회 시작");
        final prefs = await SharedPreferences.getInstance();
        final pno = prefs.getString("pno");
        final isGranted = prefs.getBool("isGranted");
        final findState = prefs.getBool('findState');

        // [2] pno가 유효한지 확인 (pno가 null 또는 빈 문자열인 경우 처리)
        print(">>>>>>>>>>>>>>>>pno조회 시작");
        if (pno == null || pno.isEmpty) {
          print("유효한 pno가 존재하지 않습니다.");
          return; // 유효하지 않은 pno로 이어지지 않도록 early return
        }

        // [3] pno 가 유효한지 DB 에서 확인
        print(">>>>>>>>>>>>>>>>pno조회 시작");
        try{
          final response = await dio.get("http://192.168.40.34:8080/patient/find?pno=$pno");
          print("pno1 성공");
          print("환자번호확인 : ${response.data}");

          if(response.data == null || response.data == '' ){
            print("존재하지 않는 pno  SharedPreferences 초기화");
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove("pno");

            return;
          }
        }catch(e){
          print(e);
          return;
        }
        print("*********pno 조회 끝");

        // [4] 현재 위치 조회
        print(">>>>>>>>>>>>>>>>위치조회 시작");
        plat = location.coords.latitude;
        plon = location.coords.longitude;

        print("1. 위치조회 권환 확인 환자번호 : $pno 권한상태 : $isGranted 와 $findState");

        // 위치 중복 체크
        if (_prevLat != null && _prevLon != null) {
          final distance = geolocator.Geolocator.distanceBetween(
            _prevLat!, _prevLon!, plat!, plon!,
          );

          if (distance < 5) {
            print("위치 중복(${distance.toStringAsFixed(2)}m) → 서버 전송 생략");
            return;
          }
        }
        // [5] 서버 백으로 전송
        print(">>>>>>>>>>>>>>>>위치전송 시작");
        try {

          if(pno != '' && isGranted == true && findState == true){
            final obj = {
              "plon" : plon,
              "plat" : plat,
              "pno" : pno
            };
            final response = await dio.post("http://192.168.40.34:8080/location/save",data: obj);

            print("안전위치확인 ${response.data}");

            // 위치 전송 성공 시 이전 위치 저장
            _prevLat = plat;
            _prevLon = plon;

            // [6] 안전반경 이탈 시 레디스에 저장된 위치정보 조회
            print(">>>>>>>>>>>>>>>>위치이탈함");
            if(response.data == false){
              final findRoute = await dio.get("http://192.168.40.34:8080/location/findroute?pno=$pno");

              if (findRoute.statusCode == 200 && findRoute.data != null) {
                routeList = findRoute.data;
                print("이탈 경로: $routeList");

                // 서버에서 해당 환자 보호자의 토큰 꺼내와서 해당 토큰에 푸시알림전송

                // 서버에서 해당 환자 보호자의 토큰 꺼내오기
                try{
                  try {
                    final findToken = await dio.get("http://192.168.40.34:8080/location/findfcmtoken?pno=$pno");
                    final fcmToken = findToken.data;

                    if (fcmToken != null) {
                      await dio.post("http://192.168.40.34:8080/location/sendNotification", data: {
                        "token": fcmToken,
                        "title": "위험 알림",
                        "body": "환자가 안전구역을 벗어났습니다!" // 환자이름 빼와서 같이 보내기
                      });
                    }
                  } catch (e) {
                    print("푸시 전송 실패: $e");
                  }

                }catch(e){
                  print(e);
                }
              } else {
                print("이탈 경로 조회 실패: ${findRoute.statusCode}");
              }


              }
            }

        }catch(e) {
          print(e);
        }

      });
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
      heartbeatInterval: 60,
    )).then((state) async { // 이미 start 가 실행중인지 여부 확인
      if (!state.enabled) {
        await bg.BackgroundGeolocation.start();
      }
    });
  }
}


// FCM 토큰을 발급받아서 pno 와 함께 서버로 보내는 함수 (나중에 보호자 화면 들어갈 때 로 위치 수정하기)
Future<void> _getFcmTokenAndSend() async {
  try {
    print("********FCM 토큰 발급 시작");
    Dio dio = Dio();
    // FCM 토큰 발급
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("********FCM 토큰 발급됨 : $fcmToken");

    // if (fcmToken != null) {
    //   final prefs = await SharedPreferences.getInstance();
    //   final gno = prefs.getString("gno") ?? "1"; // 테스트용 기본값
    //     // FCM 토큰 서버로 전송
    //   final response = await dio.post(
    //     "http://192.168.40.34:8080/location/savefcmtoken",
    //     queryParameters: {
    //       "gno": gno,
    //       "fcmToken": fcmToken,
    //     },
    //   );
    //     print("FCM 토큰 서버로 전송 성공: ${response.data}");
    //
    // }
  } catch (e) {
    print(" FCM 토큰 전송 실패: $e");
  }
}

class MyApp extends StatefulWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}
// 라우터 클래스
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 위치 추적 시작
    startLocationTracking();
  }

  void startLocationTracking() async {
    await LocationTrackingService().start();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/", // 나중에 "/" 로 바꾸기
      routes: {
        "/" : (context) => const Home(),
        "/map" : (context) => const NaverMapApp(),
        "/guardian" : (context) => const Guardian(),
        "/patientsetting" : (context) => const PatientSetting(),
        "/signup" : (context) => const Signup(),
        "/guardianmain" : (context) => const GuardianMain(),
        "/enrollpatient" : (context) => const EnrollPatient(),
        "/guardianinfo" : (context) => const GuardianInfo(),
        "/findpatient" : (context) => const FindPatient(),
        "/additionpatient" : (context) => const AdditionPatient(),
        "/updatepatient" : (context) => const UpdatePatient(),
        "/resignguardian" : (context) => const ResignGuardian(),
        "/guardianhome" : (context) => const GuardianHome(),
        "/enrollLocation" : (context) => const EnrollLocation(),
        "/changeLocation" : (context) => const ChangeLocation(),
        "/authentication" : (context) => const Authentication(),
        "/additionlocation" : (context) => const AdditionLocation(),
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
