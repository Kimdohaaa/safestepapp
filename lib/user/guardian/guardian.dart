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
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString("gno", loginGno.data.toString());

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/SafeStep_logo.PNG',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 25),
                  const Text("보호자 로그인 페이지 입니다."),
                  const SizedBox(height: 30),
                  TextField(
                    controller: gidController,
                    decoration: const InputDecoration(
                      labelText: '보호자 아이디',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: gpwdController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '보호자 비밀번호',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      "회원가입하러 가기",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      minimumSize: const Size(130, 50),
                    ),
                    child: const Text(
                      "로그인",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}