import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _initializeFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 포그라운드에서 알림 수신 시
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("포그라운드 알림 수신");
    print("title: ${message.notification?.title}");
    print("body: ${message.notification?.body}");
    print("전체 메시지: ${message.data}"); // 여기가 핵심

    // 환자 정보를 담을 변수 선언
    Map<String, dynamic>? patientDto = {};
    // 환자 번호를 담을 변수 선언
    int? pno = 0;

    // pno 호가인
    if (message.data.containsKey("pno")) {
      pno = int.parse(message.data["pno"]);
      print("FCM에서 받은 pno: $pno");

      // [*] 로그인된 gno 가져오기
      final prefs = await SharedPreferences.getInstance();
      final gno = prefs.getString("gno");

      // gno null 확인
      if (gno == null) {
        print("gno 없음");
        return;
      }

      // [*] 로그인된 gno 가 관리 중인 환자 리스트 조회
      final patientsList = await findPatientList(int.parse(gno));

      // 환자 리스트 null 확인
      if (patientsList == null || patientsList.isEmpty) {
        print("환자 리스트 없음");
        return;
      }

      // [*] FCM 알림으로 온 pno 가 현재 로그인 중인 gno 가 관리 중인 pno 이닞 확인
      final matchingPatient = patientsList.firstWhere(
            (patient) => patient['pno'].toString() == pno.toString(),
        orElse: () => null,
      );

      // [*] 관리 중인 환자가 아니라면 알림 출력 X
      if (matchingPatient == null) {
        print("관리 중인 환자 아님, 알림 무시");
        return;
      }

      // [*] 관리 중인 환자 일 시 환자 정보 조회
      patientDto = await findPatient(pno);
      print("환자 정보 조회 결과: $patientDto");

      // [*] 환자 정보가 조회될 경우 알림 출력
      if (patientDto != null && patientDto.isNotEmpty) {
        _showNotification(
          message.notification?.title,
          message.notification?.body,
          patientDto['pname'],
          patientDto['pno'],
        );
      }
    } else {
      print("pno 없음");
    }
  });


  // 백그라운드에서 알림 클릭 시
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
    print("백그라운드 알림 클릭: ${message.notification?.title}, ${message.notification?.body}");
    // 알림을 클릭한 후 처리 로직 추가하기
    // 환자 정보를 담을 변수 선언
    Map<String, dynamic>? patientDto = {};
    // 환자 번호를 담을 변수 선언
    int? pno = 0;

    // pno 호가인
    if (message.data.containsKey("pno")) {
      pno = int.parse(message.data["pno"]);
      print("FCM에서 받은 pno: $pno");

      // [*] 로그인된 gno 가져오기
      final prefs = await SharedPreferences.getInstance();
      final gno = prefs.getString("gno");

      // gno null 확인
      if (gno == null) {
        print("gno 없음");
        return;
      }

      // [*] 로그인된 gno 가 관리 중인 환자 리스트 조회
      final patientsList = await findPatientList(int.parse(gno));

      // 환자 리스트 null 확인
      if (patientsList == null || patientsList.isEmpty) {
        print("환자 리스트 없음");
        return;
      }

      // [*] FCM 알림으로 온 pno 가 현재 로그인 중인 gno 가 관리 중인 pno 이닞 확인
      final matchingPatient = patientsList.firstWhere(
            (patient) => patient['pno'].toString() == pno.toString(),
        orElse: () => null,
      );

      // [*] 관리 중인 환자가 아니라면 알림 출력 X
      if (matchingPatient == null) {
        print("관리 중인 환자 아님, 알림 무시");
        return;
      }

      // [*] 관리 중인 환자 일 시 환자 정보 조회
      patientDto = await findPatient(pno);
      print("환자 정보 조회 결과: $patientDto");

      // [*] 환자 정보가 조회될 경우 알림 출력
      if (patientDto != null && patientDto.isNotEmpty) {
        _showNotification(
          message.notification?.title,
          message.notification?.body,
          patientDto['pname'],
          patientDto['pno'],
        );
      }
    } else {
      print("pno 없음");
    }
  });

  // 앱이 처음 시작할 때 알림 클릭 시 (앱이 종료된 상태에서 알림 클릭)
  RemoteMessage? initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    print("앱 종료 상태에서 알림 클릭: ${initialMessage.notification?.title}, ${initialMessage.notification?.body}");
    _handleNotificationTap(initialMessage);
  }
}

// [#] 알림 출력 구현
void _showNotification(String? title, String? body, String? pname , int? pno) {
  final context = navigatorKey.currentState?.overlay?.context;
  if (context == null) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title ?? '긴급알림'),
        content: Text("$pname (환자번호 : $pno) 님이 $body" ?? '내용이 없습니다.'),
        actions: [
          TextButton(
            child: Text("확인"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


void _handleNotificationTap(RemoteMessage message) {
  // 알림 클릭 시 이동할 페이지나 처리할 로직 추가하기
  print("알림 클릭 후 처리: ${message.notification?.title}");
}

// [#] 환자 정보 조회 함수
Future<Map<String, dynamic>?> findPatient(int pno) async {
  Dio dio = Dio();
  try {
    final response = await dio.get(
      "http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/patient/find?pno=$pno",
    );

    print(response.data);
    return response.data;
  } catch (e) {
    print("환자 정보 조회 실패 $e");
    return null;
  }
}

// [#] 특정 보호자의 전체 환자 조회
Future<List<dynamic>?> findPatientList(int gno) async {
  print("환자정보 조회 시작");
  Dio dio = Dio();

  try {
    final response = await dio.get(
        "http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/patient/findall?gno=$gno"
    );

    // 응답이 null이 아니고, 데이터가 존재하는지 확인
    if (response.data != null && response.data.isNotEmpty) {
      print("환자 목록 조회 성공: ${response.data}");
      return response.data;  // 환자 목록 반환
    } else {
      print("환자 목록이 비어 있습니다.");
      return [];
    }
  } catch (e) {
    print("환자 정보 조회 실패: $e");
    return null;  // 오류 발생 시 null 반환
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await _initialize(); // NaverMap
  //await _getFcmTokenAndSend(); // FCM 토큰 전송
  await _initializeFCM();  // FCM 리스너 설정

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
        print("$pno 확인확인확인");
        try{
          final response = await dio.get("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/patient/find?pno=$pno");
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

        // // 위치 중복 체크
        // if (_prevLat != null && _prevLon != null) {
        //   final distance = geolocator.Geolocator.distanceBetween(
        //     _prevLat!, _prevLon!, plat!, plon!,
        //   );
        //
        //   if (distance < 5) {
        //     print("위치 중복(${distance.toStringAsFixed(2)}m) → 서버 전송 생략");
        //     return;
        //   }
        // }
        // [5] 서버 백으로 전송
        print(">>>>>>>>>>>>>>>>위치전송 시작");
        try {

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
          if(pno != '' && isGranted == true && findState == true){
            final obj = {
              "plon" : plon,
              "plat" : plat,
              "pno" : pno
            };
            final response = await dio.post("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/location/save",data: obj);

            print("안전위치확인 ${response.data}");

            // 위치 전송 성공 시 이전 위치 저장
            _prevLat = plat;
            _prevLon = plon;

            // [6] 안전반경 이탈 시 레디스에 저장된 위치정보 조회
            print(">>>>>>>>>>>>>>>>위치이탈함");
            if(response.data == false){
              final findRoute = await dio.get("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/location/findroute?pno=$pno");

              if (findRoute.statusCode == 200 && findRoute.data != null) {
                routeList = findRoute.data;
                print("이탈 경로: $routeList");


                // 서버에서 해당 환자 보호자의 토큰 꺼내오기
                try{
                  try {
                    print("토큰 반환받기");

                    final findToken = await dio.get("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/location/findfcmtoken?pno=$pno");
                    final fcmToken = findToken.data;

                    print("토큰 확인 : $fcmToken");

                    print("pno 중간 확인 $pno");
                    // if (fcmToken != null ) {
                      print("토큰 전송 시작");
                      try {
                        final response = await dio.post(
                          "http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/fcmmsg/sendNotification",
                          data: jsonEncode({
                            "targetToken": fcmToken,
                            "title": "위험 알림",
                            "body": "안전구역을 벗어났습니다!",
                            "pno" : pno
                          }),
                          options: Options(
                              headers: {
                                "Content-Type": "application/json"
                              }
                          ),
                        );

                        print("응답 결과: ${response.data}");

                      }catch(e){
                        print("알림 푸시 실패 $e");
                      }


                    //}
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


// // FCM 토큰을 발급받아서 pno 와 함께 서버로 보내는 함수 (나중에 보호자 화면 들어갈 때 로 위치 수정하기)
// Future<void> _getFcmTokenAndSend() async {
//   try {
//     print("********FCM 토큰 발급 시작");
//     Dio dio = Dio();
//     // FCM 토큰 발급
//     final fcmToken = await FirebaseMessaging.instance.getToken();
//     print("********FCM 토큰 발급됨 : $fcmToken");
//
//     if (fcmToken != null) {
//       final prefs = await SharedPreferences.getInstance();
//       final gno = prefs.getString("gno") ?? "1"; // 테스트용 기본값
//         // FCM 토큰 서버로 전송
//       final response = await dio.post(
//         "http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/location/savefcmtoken",
//         queryParameters: {
//           "gno": gno,
//           "fcmToken": fcmToken,
//         },
//       );
//         print("FCM 토큰 서버로 전송 성공: ${response.data}");
//
//     }
//   } catch (e) {
//     print(" FCM 토큰 전송 실패: $e");
//   }
// }

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
      navigatorKey: navigatorKey,
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
