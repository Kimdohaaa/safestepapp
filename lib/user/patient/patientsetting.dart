import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PatientSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PatientSettingState();
  }
}

class _PatientSettingState extends State<PatientSetting> with WidgetsBindingObserver {
  bool _isGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 앱 상태 감지 등록
    _checkPermission(); // 위젯이 처음 로드될 때 권한 확인
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 해제
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission(); // 앱이 포그라운드로 돌아오면 권한 확인
    }
  }

  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    setState(() {
      _isGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    });
  }

  Future<void> _onTogglePermission() async {
    if (_isGranted) {
      // 허용 상태: 설정으로 이동
      AppSettings.openAppSettings(); // void 함수이므로 bool 반환 없음
    } else {
      // 미허용 상태: 권한 요청
      await Geolocator.requestPermission();
      await _checkPermission(); // 최신 상태 반영
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "SafeStep ",
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
      body: Column(
        children: [
          // AppBar와 body 사이에 가로줄
          Container(
            height: 1, // 가로줄의 두께
            color: Colors.grey[300], // 가로줄 색상
          ),

          // 상단 여백과 이미지
          SizedBox(height: 59.5),
          Image.asset(
            'assets/images/SafeStep_logo.PNG', // 여기에 이미지 경로를 넣어주세요
            width: 200,
            height: 200, // 이미지 크기 조정
          ),

          SizedBox(height: 35),
          // 버튼 Row
          Text("위치 권한 설정 페이지 입니다."),

          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 환자 버튼
              Container(
                width: 250,
                height: 170,
                margin: EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: _onTogglePermission,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(
                          _isGranted ? '위치 권한 허용중' : '위치 권한 거부중',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
