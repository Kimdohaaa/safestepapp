
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:safestepapp/user/guardian/guardianinfo.dart';

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
    Text("data"),
    GuardianInfo(), // "내정보" 페이지
    Text("환자정보"), // "환자정보" 페이지
    Text("회원탈퇴"), // "회원탈퇴" 페이지
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar 배경색을 하얀색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경색을 하얀색으로 설정
        elevation: 0, // 그림자 제거
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내정보'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: '환자정보'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: '회원탈퇴'),
        ],
      ),
    );
  }
}