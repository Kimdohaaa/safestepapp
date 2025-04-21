import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ResignGuardian extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _ResignGuardianState();
  }
}

class _ResignGuardianState extends State<ResignGuardian>{
  TextEditingController gpwdController = TextEditingController();

  Dio dio = Dio();
  
  // [#] 회원탈퇴
  // 250421 진행중 ~~ 탈퇴 시 gno 랑 gpwd 서버로 보내야함
  void deleteGuardian() async{
    try{
      final response = await dio.delete("http://192.168.40.34:8080/guardian");    
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          margin: EdgeInsets.all(30),
          child: Column(
            children: [
              SizedBox(height: 53,),
              Text("회원탈퇴페이지입니다."),

              TextField(
                controller:  gpwdController,
                decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder()),
              ),

              SizedBox(height: 15), // 로그인 버튼과 텍스트 사이에 여백 추가

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
                  "환자탈퇴",
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