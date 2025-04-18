import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Guardian extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _GuardianState();
  }
}


class _GuardianState extends State<Guardian> {
  // [*] TextController
  TextEditingController gidController = TextEditingController();
  TextEditingController gpwdController = TextEditingController();

  // [*] DIO
  Dio dio = Dio();

  // [*] 토큰
  String token = "";

  // [#] 로그인 
  void login() async{
    print("로그인버튼");
    try{
      final obj = {
        "gid" : gidController.text,
        "gpwd" : gpwdController.text
      };
      final response = await dio.post("http://192.168.40.34:8080/guardian/login", data: obj);

      dynamic data = response.data;
      print("반환값 $data");
      setState(() {
        token = data;
      });
      // 로그인 성공 조건
      if (data != "" ) {
        Navigator.pushNamed(context, "/guardianmain", arguments: token);
      }else{
        print("로그인 실패");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 정보를 다시 확인하세요.")),
        );
        return;
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

      body: Center(  // Center 위젯을 사용하여 중앙 정렬
        child: Container(
          padding: EdgeInsets.all(30), // 전체 안쪽 여백 50 지정
          margin: EdgeInsets.all(30), // 전체 바깥 여백 50 지정
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,  // 세로 시작 위치로 변경
            crossAxisAlignment: CrossAxisAlignment.center,  // 가로 중앙 정렬
            children: [
              // 이미지 추가
              Image.asset(
                'assets/images/SafeStep_logo.PNG', // 이미지 경로
                width: 200, // 이미지 크기 조정
                height: 200, // 이미지 크기 조정
              ),
              SizedBox(height: 25), // 이미지와 로그인 텍스트 사이의 5px 여백

              // 로그인 텍스트
              Text("보호자 로그인 페이지 입니다."),

              SizedBox(height: 30),  // 텍스트와 TextField 사이의 여백

              TextField(
                controller: gidController,
                decoration:  InputDecoration(
                    labelText: '보호자 아이디',
                    border: OutlineInputBorder()),
              ),

              SizedBox(height: 30),

              TextField(
                controller: gpwdController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: '보호자 비밀번호',
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');  // /signup 페이지로 이동
                },
                child: Text(
                  "회원가입하러 가기",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    decoration: TextDecoration.underline,  // 밑줄 추가
                  ),
                ),
              ),

              SizedBox(height: 15),  // 로그인 버튼과 텍스트 사이에 여백 추가


              ElevatedButton(
                onPressed: login, // 버튼 클릭 시 할 작업
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 버튼 색상 파란색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 네모 모양으로 설정
                  ),
                  minimumSize: Size(130, 50), // 버튼 크기 지정
                ),
                child: Text(
                  "로그인",
                  style: TextStyle(
                    color: Colors.white, // 버튼 텍스트 색상
                    fontSize: 16, // 텍스트 크기
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )



            ],
          ),
        ),
      ),
    );
  }
}