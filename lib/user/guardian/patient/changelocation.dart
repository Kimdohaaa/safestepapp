import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safestepapp/user/guardian/guardianmain.dart';

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
      clientId: '0i2o3ztm19', // 클라이언트 ID 설정
      onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed")
  );
}

class NaverMapApp extends StatefulWidget {
  final void Function(double lat, double lon) onLocationSelected;

  const NaverMapApp({Key? key, required this.onLocationSelected}) : super(key: key);

  @override
  _NaverMapAppState createState() => _NaverMapAppState();
}

class _NaverMapAppState extends State<NaverMapApp> {
  late NaverMapController _controller;
  NMarker? _marker; // nullable로 변경

  // 현재 위치 가져오기
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 비활성화되어 있습니다.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: _getCurrentLocation(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userPos = snapshot.data!;
        final _userLatLng = NLatLng(userPos.latitude, userPos.longitude);

        return NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: _userLatLng,
              zoom: 15,
            ),
            locationButtonEnable: true,
          ),
          onMapReady: (controller) {
            _controller = controller;
          },
          onMapTapped: (point, latLng) {
            setState(() {
              // 기존 마커 제거
              if (_marker != null) {
                // _marker!.info를 사용하여 NOverlayInfo를 얻고, deleteOverlay 메서드에 전달
                _controller.deleteOverlay(_marker!.info);
              }

              // 새 마커 추가
              _marker = NMarker(
                id: 'selected_location',
                position: latLng,
              );

              _controller.addOverlay(_marker!);
              widget.onLocationSelected(latLng.latitude, latLng.longitude);
            });

          },
        );
      },
    );
  }
}

class ChangeLocation extends StatefulWidget {
  const ChangeLocation({Key? key}) : super(key: key);

  @override
  _ChangeLocationState createState() => _ChangeLocationState();
}

class _ChangeLocationState extends State<ChangeLocation> {
  Dio dio = Dio();
  double? selectedLat;
  double? selectedLon;
  int? pno;

  @override
  void initState() {
    super.initState();
    _initialize();

    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        setState(() {
          pno = args;
        });
      }
    });
  }

  // 서버로 위치 전송
  void sendLocation() async {
    if (selectedLat == null || selectedLon == null || pno == null) {
      print("위치 또는 환자 번호가 없음");
      return;
    }

    try {
      final response = await dio.post("http://192.168.40.34:8080/location", data: {
        "plon": selectedLon,
        "plat": selectedLat,
        "pno": pno,
      });

      final data = response.data;
      if (data == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("안전 위치 설정이 완료되었습니다.")),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const GuardianMain()));
      }
    } catch (e) {
      print("전송 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "SafeStep",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "안전한 위치 확인 앱",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
      body: NaverMapApp(
        onLocationSelected: (lat, lon) {
          setState(() {
            selectedLat = lat;
            selectedLon = lon;
          });
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          height: 70,
          child: Center(
            child: SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                onPressed: sendLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: const Size(130, 50),
                ),
                child: const Text(
                  "안전위치설정",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
