import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UpdatePatient extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _UpdatePatientState();
  }
}

class _UpdatePatientState extends State<UpdatePatient>{
  // [*] TextController
  TextEditingController pnameController = TextEditingController();
  TextEditingController pnumberController = TextEditingController();
  String? selectedGender;
  TextEditingController pageController = TextEditingController();
  String? selectedGrade;
  String? selectedRelation;
  TextEditingController pphoneController = TextEditingController();

  Dio dio = Dio();

  int pno = 0;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      pno = ModalRoute.of(context)!.settings.arguments as int;
      detailPatient(); // 딱 1번만 실행
      _isInit = false;
    }
  }

  // 환자 상세 조회 함수 추가 해야함

  // [#] 환자 상세 조회 함수
  Map<String, dynamic> patientDto = {};
  void detailPatient() async{
    try{
      final response = await dio.get("http://192.168.40.34:8080/patient/find?pno=$pno");

      print(response.data);
      setState(() {
        patientDto = response.data;
        print(patientDto);
        pnameController.text = patientDto['pname'];
        pnumberController.text = patientDto['pnumber'];
        pageController.text =  patientDto['page'];
        pphoneController.text = patientDto['pphone'];
        selectedGender = (patientDto['pgender'] == true) ? "여자" : "남자";
        selectedGrade = getGradeText(patientDto['pgrade']);
        selectedRelation = patientDto['relation'] as String;
      });
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
  // [#] 환자 정보 수정
  void updatePatient() async{
    print("환자정보수정시작");
    try{
      print("환자번호 : $pno");
      bool gender = false;
      if(selectedGender == "여자"){
        gender = true;
      }
      int grade = 5;
      if(selectedGrade == "1등급"){
        grade = 0;
      }else if(selectedGrade == "2등급"){
        grade = 1;
      }else if(selectedGrade == "3등급"){
        grade = 2;
      }else if(selectedGrade == "4등급"){
        grade = 3;
      }else if(selectedGrade == "5등급"){
        grade = 4;
      }else if(selectedGrade == "인지지원등급"){
        grade = 5;
      }

      final obj = {
        "pname" : pnameController.text,
        "pnumber" : pnumberController.text,
        "page" : pageController.text,
        "pphone" : pphoneController.text,
        "pgender" : gender,
        "pgrade" : grade,
        "relation" : selectedRelation,
        "pno" : pno
      };
      final response = await dio.put("http://192.168.40.34:8080/patient/update",data: obj);

      print("서버통신완");
      print(response.data);
      final data = response.data;

      if(response.data == 1){
        print("성공");
        print(response.data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("환자 정보 수정이 완료되었습니다.")),
        );
        Navigator.pushNamed(context, "/guardianmain");
      }else if(data == -1){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("유효한 전화번호 형식을 입력하세요.")),
        );
        return;
      }else if(data == -2){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("유효한 나이를 입력하세요.")),
        );
        return;
      }else if(data == -3){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이미 존재하는 전화번호입니다.")),
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
      body: Center( // Center 위젯을 사용하여 중앙 정렬
        child: Container(

          padding: EdgeInsets.all(30), // 전체 안쪽 여백 50 지정
          margin: EdgeInsets.all(30), // 전체 바깥 여백 50 지정
          child: Column(
            children: [
              SizedBox(height: 10,),
              // 로그인 텍스트
              Text("환자 정보 수정 페이지 입니다."),

              SizedBox(height: 30), // 텍스트와 TextField 사이의 여백

              TextField(
                controller: pnameController,
                decoration: InputDecoration(
                    labelText: '환자 이름',
                    border: OutlineInputBorder()),
              ),

              SizedBox(height: 10),

              TextField(
                controller: pnumberController,
                readOnly: true,
                decoration: InputDecoration(
                    labelText: '환자 주민등록번호',
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),

              TextField(
                controller: pageController,
                decoration: InputDecoration(
                    labelText: '환자 나이',
                    border: OutlineInputBorder()),
              ),

              SizedBox(height: 10),

              TextField(
                controller: pphoneController,
                decoration: InputDecoration(
                    labelText: '환자 전화번호',
                    border: OutlineInputBorder()),
              ),

              SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: '환자 성별',
                  border: OutlineInputBorder(),
                ),
                items: ['남자', '여자']
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: SizedBox(
                    width: 100, // 셀렉트 항목 너비 제한
                    child: Text(gender),
                  ),
                ))
                    .toList(),
              ),
              SizedBox(height: 10),


              DropdownButtonFormField<String>(
                value: selectedGrade,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGrade = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: '치매 등급',
                  border: OutlineInputBorder(),
                ),
                items: ['1등급', '2등급', '3등급', '4등급', '5등급', '인지지원등급']
                    .map((grade) => DropdownMenuItem(
                  value: grade,
                  child: SizedBox(
                    width: 100, // 셀렉트 박스 너비 제한
                    child: Text(grade),
                  ),
                ))
                    .toList(),
              ),
              SizedBox(height: 10),


              DropdownButtonFormField<String>(
                value: selectedRelation,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRelation = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: '환자와의 관계',
                  border: OutlineInputBorder(),
                ),
                items: ['자녀', '배우자', '기타'].map((relation) {
                  return DropdownMenuItem<String>(
                    value: relation,

                    child: Text(relation),
                  );
                }).toList(),
              ),

              SizedBox(height: 15), // 로그인 버튼과 텍스트 사이에 여백 추가


              ElevatedButton(
                onPressed: updatePatient, // 버튼 클릭 시 할 작업
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 버튼 색상 파란색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 네모 모양으로 설정
                  ),
                  minimumSize: Size(130, 50), // 버튼 크기 지정
                ),
                child: Text(
                  "환자정보수정",
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