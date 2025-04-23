// 환자번호 인증 파일 (나중에 문자 인증 기능 추가해야함) //
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:safestepapp/user/patient/patientsetting.dart';
import 'package:shared_preferences/shared_preferences.dart';


class  Authentication extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _AuthenticationState();
  }
}

class _AuthenticationState extends State< Authentication>{
  TextEditingController pphoneController = TextEditingController();

  Dio dio = Dio();
  void authentication() async{
    try{
      final pphone = pphoneController.text;
      final response = await dio.post("http://192.168.40.34:8080/location/findpno?pphone=$pphone");

      if(response.data > 0) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("pno", response.data.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("번호인증이 완료되었습니다.")),
        );

        // 위치 권한 설정 페이지로 이동
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => PatientSetting()));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("번호를 다시 확인하세요.")),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text.rich(
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

      body: Column(
        children: [
          Container(
            height: 1, // 가로줄의 두께
            color: Colors.grey[300], // 가로줄 색상
          ),

          // 상단 여백과 이미지
          SizedBox(height: 59.5),
          Image.asset(
            'assets/images/SafeStep_logo.PNG', // 여기에 이미지 경로를 넣어주세요
            width: 200,
            height: 200, // 이미지 크기 조정
          ),

          SizedBox(height: 35),
          // 버튼 Row
          Text("전화번호 인증 페이지 입니다."),

          SizedBox(height: 15),

          TextField(
            controller: pphoneController,
            decoration: InputDecoration(
                labelText: '환자 휴대폰번호',
                border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),



          SizedBox(height: 15),  // 로그인 버튼과 텍스트 사이에 여백 추가


          ElevatedButton(
            onPressed: authentication, // 버튼 클릭 시 할 작업
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // 버튼 색상 파란색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // 네모 모양으로 설정
              ),
              minimumSize: Size(130, 50), // 버튼 크기 지정
            ),
            child: Text(
              "번호확인",
              style: TextStyle(
                color: Colors.white, // 버튼 텍스트 색상
                fontSize: 16, // 텍스트 크기
                fontWeight: FontWeight.bold,
              ),
            ),
          )

        ],
      ) ,
    );
  }
}
