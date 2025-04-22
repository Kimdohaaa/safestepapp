
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:safestepapp/main/home.dart';
import 'package:safestepapp/user/guardian/findpatient.dart';
import 'package:safestepapp/user/guardian/guardian.dart';
import 'package:safestepapp/user/guardian/guardianhome.dart';
import 'package:safestepapp/user/guardian/guardianinfo.dart';
import 'package:safestepapp/user/guardian/resignguardian.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuardianMain extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _GuardianMainState();
  }
}


class _GuardianMainState extends State<GuardianMain> {

  int selectedIndex = 0; // 기본적으로 첫 번째 탭 선택

  // 페이지 리스트
  final List<Widget> _pages = [
    GuardianHome(),
    GuardianInfo(), // "내정보" 페이지
    FindPatient(), // "환자정보" 페이지
    ResignGuardian(), // "회원탈퇴" 페이지
    Text("로그아웃") // 해당 파일에 구현할거임
  ];


  Dio dio = Dio();

  // [#] 로그인 상태 확인
  bool? isLogin;
  void loginCheck() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if(token != null && token.isNotEmpty){
      print("로그인 중");
      setState(() {
        isLogin = true;
      });

    }else{
      print("비로그인 중");
    }
  }
  @override
  void initState() {
    loginCheck();
  }

  // [#] 로그아웃
  void logout() async{
    try{
      if(isLogin ==  true){
        final response = await dio.post("http://192.168.40.34:8080/guardian/logout");
        
        print(response.data);
        print("로그아웃 성공");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그아웃되었습니다.")),
        );
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
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "SafeStep ", // SafeStep 텍스트
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


      // *** body 에 지도 출력하기 *** //
      body: _pages[selectedIndex], // 선택된 페이지 표시
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white, // 배경색 흰색
          border: Border(
            top: BorderSide(
              color: Colors.black, // 검은색 테두리
              width: 1, // 1px
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white, // 이중 설정이지만 안정성 위해 유지
          currentIndex: selectedIndex,
          onTap: (index) {
            if (index == 4) {
              logout(); // 로그아웃 처리
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            } else {
              setState(() {
                selectedIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '내정보'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: '환자정보'),
            BottomNavigationBarItem(icon: Icon(Icons.outbond), label: '회원탈퇴'),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: '로그아웃'),
          ],
        ),
      ),

    );
  }
}