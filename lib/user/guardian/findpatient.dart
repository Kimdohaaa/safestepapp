import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class FindPatient extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _FindPatientState();
  }
}

// 나중에 환자 선택 시 해당 환자의 현재 위치를 표시하는 페이지로 이동되는 기능 추가하기

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
  // [#] 보호자가 등록한 환자 리스트 조회
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
      case 0:
        return "1등급";
      case 1:
        return "2등급";
      case 2:
        return "3등급";
      case 3:
        return "4등급";
      case 4:
        return "5등급";
      case 5:
        return "인지지원등급";
      default:
        return "등급 없음";
    }
  }

  // [#] 환자 정보 삭제
  void deletePatient(pno) async{
    try{
      // 비밀번호 확인 다이얼로그 호출
      bool isPasswordCorrect = await _showPasswordDialog(context);

      if (!isPasswordCorrect) {
        // 비밀번호가 틀리면 삭제하지 않음
        return;
      }
      final response = await dio.delete("http://192.168.40.34:8080/patient?pno=$pno");

      if(response.data == true){
        print("환자정보삭제 완료");
        setState(() {
          findPatients(gno);
        });
      }else{
        print("환자정보삭제 실패");
      }
    }catch(e){
      print(e);
    }
  }

  // 비밀번호 입력 다이얼로그 띄우기
  Future<bool> _showPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('비밀번호 입력'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '비밀번호',
              hintText: '비밀번호를 입력해주세요',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);  // 취소
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                String password = passwordController.text;
                if (password == "정확한 비밀번호") {
                  Navigator.of(context).pop(true);  // 비밀번호 맞으면 true 반환
                } else {
                  Navigator.of(context).pop(false);  // 비밀번호 틀리면 false 반환
                }
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    ) ?? false;  // 다이얼로그가 취소되면 false 반환
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
                    return Card(
                      color: Colors.white, // 배경색 흰색
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 1), // 1px 검은 테두리
                        borderRadius: BorderRadius.circular(8), // 원하는 만큼 라운딩 (선택사항)
                      ),
                      child: ListTile(
                        title: Text("이름 : ${patient['pname']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                          children: [
                            Text("주민등록번호 : ${patient['pnumber']}"),
                            Text("성별 : ${patient['pgender'] == true ? '여자' : patient['pgender'] == false ? '남자' : '정보 없음'}"),
                            Text("나이 : ${patient['page']}"),
                            Text("치매등급 : ${getGradeText(patient['pgrade'])}"),
                            Text("관계 : ${patient['relation']}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/changeLocation", arguments: patient['pno']);
                              },
                              icon: Icon(Icons.location_on),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/updatepatient", arguments: patient['pno']);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                deletePatient(patient['pno']);
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
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