// 로그인 파일 //
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Guardian extends StatefulWidget{
  const Guardian({super.key});

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

  int gno = 0;
  // [#] 로그인 
  void login() async{
    print("로그인버튼");
    // dio.options.connectTimeout = 10000;  // 연결 타임아웃 (10초)
    // dio.options.receiveTimeout = 10000;  // 응답 타임아웃 (10초)
    dio.options.connectTimeout = const Duration(milliseconds: 50000);
    try{
      final obj = {
        "gid" : gidController.text,
        "gpwd" : gpwdController.text
      };
      final response = await dio.post("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/guardian/login", data: obj);

      dynamic data = response.data;

      // 로그인 성공 조건
      if (data != "" ) {
        Navigator.pushNamed(context, "/guardianmain");

        // 토큰 전역변수로 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data);

        // gno 전역변수로 저장
        try{
          final loginGno = await dio.get("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/guardian/findgno");
          print("로그인된 gno 확인 : $loginGno.data");
          gno = loginGno.data;

          if(gno > 0){
            _getFcmTokenAndSend();
          }
        }catch(e){

          print(e);
        }

      }else{
        print("로그인 실패");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인 정보를 다시 확인하세요.")),
        );
        return;
      }
    }catch(e){
      print(e);
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

      if (fcmToken != null) {

        print("gno 확인 : $gno");
        // FCM 토큰 서버로 전송
        final response = await dio.post(
          "http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/location/savefcmtoken",
          queryParameters: {
            "gno": gno,
            "fcmToken": fcmToken,
          },
        );
        print("FCM 토큰 서버로 전송 성공: ${response.data}");

      }
    } catch (e) {
      print(" FCM 토큰 전송 실패: $e");
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
        title: const Text.rich(
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
          padding: const EdgeInsets.all(10), // 전체 안쪽 여백 50 지정
          margin: const EdgeInsets.all(10), // 전체 바깥 여백 50 지정
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
              const SizedBox(height: 25), // 이미지와 로그인 텍스트 사이의 5px 여백

              // 로그인 텍스트
              const Text("보호자 로그인 페이지 입니다."),

              const SizedBox(height: 30),  // 텍스트와 TextField 사이의 여백

              TextField(
                controller: gidController,
                decoration:  const InputDecoration(
                    labelText: '보호자 아이디',
                    border: OutlineInputBorder()),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: gpwdController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: '보호자 비밀번호',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');  // /signup 페이지로 이동
                },
                child: const Text(
                  "회원가입하러 가기",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    decoration: TextDecoration.underline,  // 밑줄 추가
                  ),
                ),
              ),

              const SizedBox(height: 15),  // 로그인 버튼과 텍스트 사이에 여백 추가


              ElevatedButton(
                onPressed: login, // 버튼 클릭 시 할 작업
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 버튼 색상 파란색
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 네모 모양으로 설정
                  ),
                  minimumSize: const Size(130, 50), // 버튼 크기 지정
                ),
                child: const Text(
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