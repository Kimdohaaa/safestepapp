
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuardianInfo extends StatefulWidget{
  const GuardianInfo({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GuardianInfo();
  }
}


class _GuardianInfo extends State<GuardianInfo> {
  // [*] TextController
  TextEditingController gnoController = TextEditingController();
  TextEditingController gidController = TextEditingController();
  // TextEditingController gpwdController = TextEditingController();
  TextEditingController gnameController = TextEditingController();
  TextEditingController gemailController = TextEditingController();
  TextEditingController gphoneController = TextEditingController();

  // [*] Dio
  Dio dio = Dio();

  // [*] 서버 반환값을 저장할 객체
  Map<String, dynamic> guardianInfo = {};

  @override
  void initState() {
    loginCheck();
  }

  // [#] 로그인 여부 확인
  bool? isLogin;
  void loginCheck() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if(token != null && token.isNotEmpty){
      print("로그인중");
      setState(() {
        isLogin = true;
        findInfo(token);
      });
    }else{
      print("비로그인중");
      setState(() {
        isLogin = false;
      });
    }
  }
  // [#] 내 정보 조회
  void findInfo(token) async {
    try{
      final response = await dio.get(
        "http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/guardian/info",
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
    print("정보수정 클릭");
    try{
      print("정보수정중");
      print(gnoController.text);
      // 아이디 텍스트 필드는 수정 안되게 막아야 됨 //
      final obj = {
        "gid" : gidController.text,
        "gname" : gnameController.text,
        "gemail" : gemailController.text,
        "gphone" : gphoneController.text,
        "gno" : gnoController.text // gno 받아와야됨
      };

      final response = await dio.put("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/guardian/update", data: obj);
      print(response.data);
      final data = response.data;
      if(response.data == 1){
        Navigator.pushNamed(context, "/guardianmain");
        print("정보수정성공");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("정보 수정이 완료되었습니다.")),
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

          padding: const EdgeInsets.all(30), // 전체 안쪽 여백 50 지정
          margin: const EdgeInsets.all(30), // 전체 바깥 여백 50 지정
          child: Column(
            children: [
              const SizedBox(height: 53,),
              // 로그인 텍스트
              const Text("마이페이지 입니다."),

              const SizedBox(height: 30),  // 텍스트와 TextField 사이의 여백

              TextField(
                controller: gidController,
                readOnly: true,
                decoration:  const InputDecoration(
                    labelText: '보호자 아이디',
                    border: OutlineInputBorder()),
              ),

              const SizedBox(height: 10),


              TextField(
                controller: gnameController,
                decoration: const InputDecoration(
                    labelText: '보호자 이름',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: gemailController,
                decoration: const InputDecoration(
                    labelText: '보호자 이메일',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: gphoneController,
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: '보호자 휴대폰번호',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),



              const SizedBox(height: 15),  // 로그인 버튼과 텍스트 사이에 여백 추가


              ElevatedButton(
                onPressed: update, // 버튼 클릭 시 할 작업
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 버튼 색상 파란색
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 네모 모양으로 설정
                  ),
                  minimumSize: const Size(130, 50), // 버튼 크기 지정
                ),
                child:const Text(
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