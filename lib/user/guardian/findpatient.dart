import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class FindPatient extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _FindPatientState();
  }
}

class _FindPatientState extends State<FindPatient>{
  Dio dio = Dio();

  int gno = 0;
  // [*] 로그인된 gno 가져오기
  void findGno() async{
    try{
      final response = await dio.get("http://192.168.40.34:8080/guardian/findgno");

      print(response.data);
      if(response.data > 0){
        findPatients(response.data);
        setState(() {
          gno = response.data;
        });
      }
    }catch(e){
      print(e);
    }
  }

  @override
  void initState() {
    findGno();
  }
  // [*] 보호자가 등록한 환자 리스트 조회
  List<dynamic> patientsList = [];
  void findPatients(int gno) async{
    print("환자정보 조회 시작");
    try{
      final response = await dio.get("http://192.168.40.34:8080/patient/findall?gno=$gno");

      if(response.data != null){
        print(response.data);

        
        setState(() {

          patientsList = response.data;
        });
      }
    }catch(e){
      print(e);
    }
  }

  // [#] 치매 등급 문자열로 출력
  String getGradeText(dynamic pgrade) {
    switch (pgrade) {
      case 1:
        return "1등급";
      case 2:
        return "2등급";
      case 3:
        return "3등급";
      case 4:
        return "4등급";
      case 5:
        return "5등급";
      case 0:
        return "인지지원등급";
      default:
        return "등급 없음";
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          children: [
            Expanded( // Column() 위젯 내에서 ListView() 위젯사용 시 Expanded() 위젯 안에서 사용해야함
                child: ListView(
                  children: // map() 사용 시 반환값이 List 이기 때문에 대괄호 생략
                  patientsList.map((patient) {
                    return Card(child: ListTile(
                        title: Text("이름 : ${patient['pname']}"),
                        subtitle: Column(
                          children: [
                            Text("주민등록번호 : ${patient['pnumber']}"),
                            Text("성별 : ${patient['pgender'] == true ? '여자' : patient['pgender'] == false ? '남자' : '정보 없음'}"),
                            Text("나이 : ${patient['page']}"),
                            Text("치매등급 : ${getGradeText(patient['pgrade'])}"),
                            Text("관계 : ${patient['relation']}"),
                            // 변수값만 출력 시 : "문자열 $변수명"
                            // 객체의 Key의 value 출력 시 : "문자열 ${변수명['key']}"
                          ],
                        ),


                        trailing: // trailing : ListTile 오른 쪽 끝에 표시되는 위젯
                        Row( // Row() : 하위 위젯 가로 배치
                            mainAxisSize : MainAxisSize.min, // trailing 하위 위젯의 사이지를 자동으로 할당
                            children: [

                              IconButton(
                                  onPressed: () => {Navigator.pushNamed(context, "/updatepatient", arguments: patient['pno'])}, // pno 보내야됨 !!!
                                  icon: Icon(Icons.edit)
                              ),
                            ]
                        )
                    ),
                    );
                  }).toList(),


                )
            ),
            ElevatedButton(
              onPressed: ()=>{Navigator.pushNamed(context, "/additionpatient", arguments: gno)}, // 버튼 클릭 시 할 작업
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼 색상 파란색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // 네모 모양으로 설정
                ),
                minimumSize: Size(130, 50), // 버튼 크기 지정
              ),
              child: Text(
                "환자 추가",
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
    );
  }
}