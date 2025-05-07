import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safestepapp/user/guardian/guardian.dart';

// 경도와 위도를 저장할 변수
double plon = 0.0; // 경도
double plat = 0.0; // 위도

// 지도 초기화하기
Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
      clientId: '0i2o3ztm19',     // 클라이언트 ID 설정
      onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed")
  );
}

class NaverMapApp extends StatefulWidget {
  const NaverMapApp({Key? key}) : super(key: key);

  @override
  _NaverMapAppState createState() => _NaverMapAppState();
}

class _NaverMapAppState extends State<NaverMapApp> {
  late NaverMapController _controller; // NaverMapController를 사용하여 지도 컨트롤
  late NMarker _marker; // 마커 객체
  late NLatLng _userLatLng; // 현재 사용자의 위도, 경도를 저장할 변수

  @override
  void initState() {
    super.initState();
    _marker = NMarker(
      id: 'current_location',
      position: NLatLng(plat, plon), // 초기 마커 위치
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(  // 현재 위치를 가져오는 FutureBuilder
      future: _getCurrentLocation(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userPos = snapshot.data!;
        _userLatLng = NLatLng(userPos.latitude, userPos.longitude); // 위치 갱신

        return NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: _userLatLng,  // 초기 카메라 위치
              zoom: 15,
            ),
            locationButtonEnable: true,
          ),
          onMapReady: (controller) {
            log("onMapReady", name: "onMapReady");
            _controller = controller;

            // 초기 위치에 마커 추가
            _controller.addOverlay(_marker);
          },
          onMapTapped: (point, latLng) { // 파라미터 타입 변경
            setState(() {
              // 마커의 위치 업데이트
              _marker = NMarker(
                id: 'new_location',
                position: latLng, // NLatLng로 변환된 값
              );
            });

            // 지도에 마커 추가 또는 업데이트
            _controller.addOverlay(_marker);  // 새 마커 위치를 반영

            // 경도와 위도 로그로 출력
            plon = latLng.longitude;
            plat = latLng.latitude;
            log("선택한 위도 : $plat, 선택한 경도: $plon", name: "onMapTapped");
          },
        );
      },
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

// 환자의 위치 등록 파일 //
class EnrollLocation extends StatefulWidget {
  const EnrollLocation({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EnrollLocationState();
  }
}

class _EnrollLocationState extends State<EnrollLocation> {
  Dio dio = Dio();
  
  int? pno; // 전달받을 환자 번호를 저장할 변수

  @override
  void initState() {
    super.initState();
    _initialize(); // 네이버맵 초기화

    // initState에서 arguments를 안전하게 접근하기 위해 Future.delayed 사용
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is int) {
        setState(() {
          pno = args;
          print("전달받은 환자 번호 (EnrollLocation): $pno");
        });
      } else {
        print("환자 번호가 전달되지 않았거나 타입이 다릅니다.");
      }
    });
  }

  // [#] 사용자가 선택한 위도와 경도를 서버로 보내기
  void sendLocation() async{
    try{
      final sendData = {
        "plon" : plon,
        "plat" : plat,
        "pno" : pno
      };
      final response = await dio.post("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/location", data:  sendData);

      final data = response.data;
      print("위치 저장결과 $data");

      if(data == true){
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Guardian()));
      }
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar 배경색을 하얀색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경색을 하얀색으로 설정
        elevation: 0, // 그림자 제거
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "SafeStep", // SafeStep 텍스트
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 27, // 폰트 크기 30px
                  fontWeight: FontWeight.bold, // 굵게 설정
                ),
              ),
              TextSpan(
                text: "안전한 위치 확인 앱", // 안전한 위치 확인 앱 텍스트
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14, // 폰트 크기 15px
                  fontWeight: FontWeight.w300, // 얇게 설정
                ),
              ),
            ],
          ),
        ),
      ),
      body: const NaverMapApp(), // 지도 위젯 출력
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // 배경색 흰색
        child: Container(
          height: 70, // 전체 높이 50
          decoration: const BoxDecoration(
            border: Border(

            ),
          ),
          child: Center(
            child: SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                onPressed: sendLocation, // 버튼 클릭 시 할 작업
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 버튼 색상 파란색
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 네모 모양으로 설정
                  ),
                  minimumSize: const Size(130, 50), // 버튼 크기 지정
                ),
                child: const Text(
                  "안전위치설정",
                  style: TextStyle(
                    color: Colors.white, // 버튼 텍스트 색상
                    fontSize: 16, // 텍스트 크기
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ),
          ),
        ),
      ),

    );
  }
}
