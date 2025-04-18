import 'package:flutter/material.dart';

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
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

      body: Column(
        children: [
          // AppBar와 body 사이에 가로줄
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

          SizedBox(height: 50),
          // 버튼 Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 환자 버튼
              Container(
                width: 150,
                height: 170,
                margin: EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, "/patient"),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.white, size: 40),
                      SizedBox(height: 10),
                      Text(
                        "환자",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 보호자 버튼
              Container(
                width: 150,
                height: 170,
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, "/guardian"),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, color: Colors.white, size: 40),
                      SizedBox(height: 10),
                      Text(
                        "보호자",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
