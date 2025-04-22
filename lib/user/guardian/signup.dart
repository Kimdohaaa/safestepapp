import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget{
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
      final obj = {
        "gid" : gidController.text,
        "gpwd" : gpwdController.text,
        "gname" : gnameController.text,
        "gemail" : gemailController.text,
        "gphone" : gphoneController.text
      };
      
      final response = await dio.post("http://192.168.40.34:8080/guardian/signup", data: obj);

      if(response.data > 0){
        print(response.data);
        Navigator.pushNamed(context, "/enrollpatient", arguments: response.data);
      }else{

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
                text: "SafeStep", // SafeStep 텍스트
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
            children: [
              SizedBox(height: 53,),
              // 로그인 텍스트
              Text("보호자 회원가입 페이지 입니다."),

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
                onPressed: signup, // 버튼 클릭 시 할 작업
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 버튼 색상 파란색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 네모 모양으로 설정
                  ),
                  minimumSize: Size(130, 50), // 버튼 크기 지정
                ),
                child: Text(
                  "회원가입",
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