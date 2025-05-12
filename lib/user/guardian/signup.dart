import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget{
  const Signup({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignupState();
  }
}
class _SignupState extends State<Signup> {
  // [*] TextController
  TextEditingController gidController = TextEditingController();
  TextEditingController gpwdController = TextEditingController();
  TextEditingController gnameController = TextEditingController();
  TextEditingController gemailController = TextEditingController();
  TextEditingController gphoneController = TextEditingController();

  // [*] DIO
  Dio dio = Dio();
  
  // [#] 회원가입
  void signup() async{
    try{
      print("회원가입버튼 테스트 : ${gidController.text}");

      if (gidController.text == '' ||
          gpwdController.text == '' ||
          gnameController.text == '' ||
          gemailController.text == '' ||
          gphoneController.text == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("모든 항목을 입력하세요")),
        );
        return;
      }

      final obj = {
        "gid" : gidController.text,
        "gpwd" : gpwdController.text,
        "gname" : gnameController.text,
        "gemail" : gemailController.text,
        "gphone" : gphoneController.text
      };
      
      final response = await dio.post("http://Springweb-env.eba-a3mepmvc.ap-northeast-2.elasticbeanstalk.com/guardian/signup", data: obj);

      final data = response.data;
      if(response.data > 0){
        print(response.data);
        Navigator.pushNamed(context, "/enrollpatient", arguments: response.data);
      }else if(data == -1){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미 존재하는 아이디입니다.")),
        );
        return;
      }else if(data == -2){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미 존재하는 이메일입니다.")),
        );
        return;
      }else if(data == -3){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미 존재하는 전화번호입니다.")),
        );
        return;
      }else if(data == -4){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("유효한 전화번호 형식을 입력하세요.")),
        );
        return;
      }else if(data == -5){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("아이디와 비밀번호의 길이는 3 ~ 15 이내입니다.")),
        );
        return;
      }else if(data == 0){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("관리자에게 문의하세요.")),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "SafeStep",
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
        child: SingleChildScrollView( // SingleChildScrollView 추가
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              margin: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const SizedBox(height: 53),
                  const Text("보호자 회원가입 페이지 입니다."),
                  const SizedBox(height: 30),
                  TextField(
                    controller: gidController,
                    decoration: const InputDecoration(
                      labelText: '보호자 아이디',
                      hintText: '3 ~ 13자 이내',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: gpwdController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '보호자 비밀번호',
                      hintText: '3 ~ 13자 이내',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: gnameController,
                    decoration: const InputDecoration(
                      labelText: '보호자 이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: gemailController,
                    decoration: const InputDecoration(
                      labelText: '보호자 이메일',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: gphoneController,
                    decoration: const InputDecoration(
                      labelText: '보호자 휴대폰번호',
                      hintText: '- 없이 11 자리 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      minimumSize: const Size(130, 50),
                    ),
                    child: const Text(
                      "회원가입",
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