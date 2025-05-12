import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:safestepapp/main/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResignGuardian extends StatefulWidget{
  const ResignGuardian({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ResignGuardianState();
  }
}

class _ResignGuardianState extends State<ResignGuardian>{
  TextEditingController gpwdController = TextEditingController();

  Dio dio = Dio();

  int gno = 0;
  // [#] 현재 로그인 중인 gno 가져오기
  void findGno() async {
    try{
      final response = await dio.get("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/guardian/findgno");

      if(response.data > 0){
        setState(() {
          gno = response.data;
        });

        print(gno);
      }
    }catch(e){
      print(e);
    }
  }

  @override
  void initState() {
    findGno();
  }

  // [#] 회원탈퇴
  void deleteGuardian() async{
    try{
      String gpwd = gpwdController.text;
      if(gno > 0) {
        final response = await dio.delete("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/guardian?gno=$gno&gpwd=$gpwd");

        if(response.data == true){
          print("회원탈퇴성공");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("회원탈퇴처리 되었습니다.")),
          );

          // SharedPreferences에서 gno와 token 삭제
          Future<void> _clearStoredLoginData() async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove("gno");
            await prefs.remove("token");
            print("초기화: gno, token 삭제됨");
          }

          // 메인페이지로 이동 시키기
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const Home())
          );
        }else{
          print("회원탈퇴 실패");
        }
      }
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(  // SafeArea로 감쌈
        child: SingleChildScrollView(  // SingleChildScrollView로 감쌈
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              margin: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const SizedBox(height: 53),
                  const Text("회원탈퇴페이지입니다."),

                  TextField(
                    controller: gpwdController,
                    decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 15), // 로그인 버튼과 텍스트 사이에 여백 추가

                  ElevatedButton(
                    onPressed: deleteGuardian, // 버튼 클릭 시 할 작업
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // 버튼 색상 파란색
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 네모 모양으로 설정
                      ),
                      minimumSize: const Size(130, 50), // 버튼 크기 지정
                    ),
                    child: const Text(
                      "회원탈퇴",
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
        ),
      ),
    );
  }


}