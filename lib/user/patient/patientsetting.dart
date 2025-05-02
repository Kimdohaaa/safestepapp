import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientSetting extends StatefulWidget {
  const PatientSetting({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PatientSettingState();
  }
}

class _PatientSettingState extends State<PatientSetting> with WidgetsBindingObserver {
  bool _isGranted = false; // 나중에
  bool _isState = false; // 위치 조회 여부를 결정할 변수

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 앱 상태 감지 등록
    _checkPermission(); // 위젯이 처음 로드될 때 권한 확인
    _loadPermission(); // SharedPreferences에서 권한 상태를 불러옴
    _loadFindState();

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
    // 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();

    // 권한이 없으면 권한 요청
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // 권한 상태를 SharedPreferences에 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGranted', permission == LocationPermission.always || permission == LocationPermission.whileInUse);

    // 상태 업데이트
    setState(() {
      _isGranted = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    });

    // 권한 상태 확인 (디버깅용)
    print(">> 현재권한: $permission");
    print(">> 전역변수에 저장도니 현재 권한 : $_isGranted");
  }

  // 위치 권한 버튼 클릭 시 (나중에 확인해)
  Future<void> _onTogglePermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool currentGranted = prefs.getBool('isGranted') ?? false;
    bool newGranted = !currentGranted;

    await prefs.setBool('isGranted', newGranted); // 저장
    setState(() {
      _isGranted = newGranted;
    });
    if (!_isGranted) {
      // 위치 권한 미허용 상태: 설정으로 이동
      AppSettings.openAppSettings();
    } else {
      // 위치 권한 허용 상태: 권한 요청
      await Geolocator.requestPermission();
      await _checkPermission(); // 최신 권한 상태를 반영
    }
  }

  // _isState SharedPreferences 에 저장
  Future<void> _saveFindState(bool state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('findState', state);
  }

  // SharedPreferences 에서 _isState 가져오기
  Future<void> _loadFindState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isState = prefs.getBool('findState') ?? false;

    });
  }

  // _isGranted SharedPreferences에 저장
  Future<void> _savePermission(bool isGranted) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGranted', isGranted); // 권한 상태 저장
  }

  // SharedPreferences에서 _isGranted 불러오기
  Future<void> _loadPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGranted = prefs.getBool('isGranted') ?? false; // 권한 상태 불러오기
    });
    print("권한 상태 : $_isGranted");
  }

  // 위치조회 여부 버튼 클릭 시
  Future<void> _onFindStateToggle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool currentState = prefs.getBool('findState') ?? false;
    bool newState = !currentState;

    await prefs.setBool('findState', newState); // 저장
    setState(() {
      _isState = newState;
    });
    print("조회 상태 : $_isState");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text.rich(
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
          const SizedBox(height: 59.5),
          Image.asset(
            'assets/images/SafeStep_logo.PNG', // 여기에 이미지 경로를 넣어주세요
            width: 200,
            height: 200, // 이미지 크기 조정
          ),

          const SizedBox(height: 35),
          // 버튼 Row
          const Text("위치 권한 설정 페이지 입니다."),

          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 환자 버튼
              Container(
                width: 250,
                height: 100,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: _isGranted ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: _onTogglePermission,
                  child: Center( // Center 위젯을 사용하여 텍스트를 정확히 중앙에 배치
                    child: Text(
                      _isGranted ? '위치 권한 허용중' : '위치 권한 거부중',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 위치 조회 상태 버튼
              Container(
                width: 250,  // 위치 권한 버튼과 같은 너비
                height: 100, // 위치 권한 버튼과 같은 높이
                decoration: BoxDecoration(
                  color: _isState ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: //() => {
                    // 테스트용
                  //Navigator.pushNamed(context, "/findlocation")},
                  _onFindStateToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // 투명하게 만들어서 container 배경색 유지
                    elevation: 0, // 그림자 제거
                    minimumSize: const Size(150, 50), // 이 부분은 더 이상 필요
                  ),
                  child: Center( // Center 위젯으로 텍스트 중앙 정렬
                    child: Text(
                      _isState ? '위치 조회 허용중' : '위치 조회 거부중',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
