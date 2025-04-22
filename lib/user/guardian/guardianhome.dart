import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

// 보호자 메인 페잊 (해당 보호자에게 등록되어 잇는 환자의 현재 위치 조회)

// 지도 초기화하기
Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
      clientId: '0i2o3ztm19',     // 클라이언트 ID 설정
      onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed")
  );
}
class NaverMapApp extends StatelessWidget {
  const NaverMapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
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
class GuardianHome extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _GuardianHomeState();
  }
}

class _GuardianHomeState extends State<GuardianHome>{

  @override
  void initState() {
    super.initState();
    _initialize(); // 네이버맵 초기화
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NaverMapApp(), // 지도 출력
    );
  }
}