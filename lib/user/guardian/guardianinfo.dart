import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GuardianInfo extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _GuardianInfo();
  }
}


class _GuardianInfo extends State<GuardianInfo> {
  // [*] TextController
  TextEditingController gnoController = TextEditingController();
  TextEditingController gidController = TextEditingController();
  TextEditingController gpwdController = TextEditingController();
  TextEditingController gnameController = TextEditingController();
  TextEditingController gemailController = TextEditingController();
  TextEditingController gphoneController = TextEditingController();

  // [*] Dio
  Dio dio = Dio();

  // [*] 서버 반환값을 저장할 객체
  Map<String, dynamic> guardianInfo = {};

  // [*] 토큰 가져오기
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String token = ModalRoute.of(context)!.settings.arguments as String;

    findInfo(token);
  }
  // [#] 내 정보 조회
  void findInfo(token) async {
    try{
      final response = await dio.get(
        "http://192.168.40.34:8080/guardian/info",
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
      );

      if(response.data != null){
        guardianInfo = Map<String, dynamic>.from(response.data);
        print(guardianInfo); // 콘솔에 전체 map 출력;


        setState(() {
          gnoController.text = guardianInfo['gno'].toString();
          gidController.text = guardianInfo['gid'] ?? ''; // 값이 없으면 빈 문자열로 처리
          // gpwdController.text = guardianInfo['gpwd'] ?? '';
          gnameController.text = guardianInfo['gname'] ?? '';
          gemailController.text = guardianInfo['gemail'] ?? '';
          gphoneController.text = guardianInfo['gphone'] ?? '';
        });
      }
    }catch(e){
      print(e);
    }
  }

  // [#] 내 정보 수정
  void update() async{
    try{
      // 아이디 텍스트 필드는 수정 안되게 막아야 됨 //
      final obj = {
        "gpwd" : gpwdController.text,
        "gname" : gnameController.text,
        "gemail" : gemailController.text,
        "gphone" : gphoneController.text,
        "gno" : 4 // gno 받아와야됨
      };

      final response = await dio.put("http://192.168.40.34:8080/guardian/update", data: obj);

      if(response.data == true){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GuardianInfo()), // 현재 페이지로 다시 이동
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


      body: Center(  // Center 위젯을 사용하여 중앙 정렬
        child: Container(

          padding: EdgeInsets.all(30), // 전체 안쪽 여백 50 지정
          margin: EdgeInsets.all(30), // 전체 바깥 여백 50 지정
          child: Column(
            children: [
              SizedBox(height: 53,),
              // 로그인 텍스트
              Text("마이페이지 입니다."),

              SizedBox(height: 30),  // 텍스트와 TextField 사이의 여백

              TextField(
                controller: gidController,
                decoration:  InputDecoration(
                    labelText: '보호자 아이디',
                    border: OutlineInputBorder()),
              ),

              SizedBox(height: 10),

              TextField(
                controller: gpwdController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: '보호자 비밀번호',
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),

              TextField(
                controller: gnameController,
                decoration: InputDecoration(
                    labelText: '보호자 이름',
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),

              TextField(
                controller: gemailController,
                decoration: InputDecoration(
                    labelText: '보호자 이메일',
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),

              TextField(
                controller: gphoneController,
                decoration: InputDecoration(
                    labelText: '보호자 휴대폰번호',
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),



              SizedBox(height: 15),  // 로그인 버튼과 텍스트 사이에 여백 추가


              ElevatedButton(
                onPressed: (){}, // 버튼 클릭 시 할 작업
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 버튼 색상 파란색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 네모 모양으로 설정
                  ),
                  minimumSize: Size(130, 50), // 버튼 크기 지정
                ),
                child: Text(
                  "정보수정",
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