import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AdditionPatient extends StatefulWidget{
  const AdditionPatient({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AdditionPatientState();
  }
}

class _AdditionPatientState extends State<AdditionPatient> {
  // [*] TextController
  TextEditingController pnameController = TextEditingController();
  TextEditingController pnumberController = TextEditingController();
  String? selectedGender;
  TextEditingController pageController = TextEditingController();
  String? selectedGrade;
  String? selectedRelation;
  TextEditingController pphoneController = TextEditingController();

  // [*] DIO
  Dio dio = Dio();

  // [#] 보호자 PK 키 가져오기 (회원가입 후 이동 시 매개변수) => 나중에 로그인 후 등록 시 dio로 가져오는 코드 추가
  int gno = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // signup.dart 파일에서 받아옴
    gno = ModalRoute.of(context)!.settings.arguments as int;
    print(gno);
  }

  // [#] 환자 등록
  void enroll() async {
    try{
      // 모든 정보 입력 유효성 검사
      if (pnameController.text == '' ||
          pnumberController.text == '' ||
          selectedGrade == null || selectedGrade == '' ||
          selectedGender == null || selectedGender == '' ||
          pphoneController.text == '' ||
          selectedRelation == null || selectedRelation == '' ||
          pageController.text == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("모든 항목을 입력하세요")),
        );
        return;
      }

      // 환자 나이 유효성 검사
      int? age = int.tryParse(pageController.text);

      if (age == null || age < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("나이는 숫자로 입력하고 0 이상이어야 합니다")),
        );
        return;
      }

      print(gno);
      bool gender = false;
      if(selectedGender == "여자"){
        gender = true;
      }
      int grade = 0;
      if(selectedGender == "1등급"){
        grade = 1;
      }else if(selectedGrade == "2등급"){
        grade = 2;
      }else if(selectedGrade == "3등급"){
        grade = 3;
      }else if(selectedGrade == "4등급"){
        grade = 4;
      }else if(selectedGrade == "5등급"){
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
        "gno" : gno
      };

      final response = await dio.post("http://192.168.40.34:8080/patient/enroll", data: obj);

      final data = response.data;
      if(response.data > 0){
        print("성공");
        print(response.data);
        // 환자 기본 위치 지정 페이지로 이동 (등록된 환자번호 매개변수로 전달)
        Navigator.pushNamed(context, "/additionlocation", arguments: data);

      }else if(data == -1){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미 존재하는 주민등록번호입니다.")),
        );
        return;
      }else if(data == -2){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("유효한 나이를 입력하세요.")),
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
          const SnackBar(content: Text("유효한 주민등록번호 형식을 입력하세요.")),
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

      // AppBar 배경색을 하얀색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경색을 하얀색으로 설정
        elevation: 0, // 그림자 제거
        title: const Text.rich(
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

          padding: const EdgeInsets.all(30), // 전체 안쪽 여백 50 지정
          margin: const EdgeInsets.all(30), // 전체 바깥 여백 50 지정
          child: Column(
            children: [
              const SizedBox(height: 10,),
              // 로그인 텍스트
              const Text("환자 추가 페이지 입니다."),

              const SizedBox(height: 30), // 텍스트와 TextField 사이의 여백

              TextField(
                controller: pnameController,
                decoration: const InputDecoration(
                    labelText: '환자 이름',
                    border: OutlineInputBorder()),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: pnumberController,
                decoration: const InputDecoration(
                    labelText: '환자 주민등록번호',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: pageController,
                decoration: const InputDecoration(
                    labelText: '환자 나이',
                    border: OutlineInputBorder()),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: pphoneController,
                decoration: const InputDecoration(
                    labelText: '환자 전화번호',
                    border: OutlineInputBorder()),
              ),

              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
                decoration: const InputDecoration(
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
              const SizedBox(height: 10),


              DropdownButtonFormField<String>(
                value: selectedGrade,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGrade = newValue;
                  });
                },
                decoration: const InputDecoration(
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
              const SizedBox(height: 10),


              DropdownButtonFormField<String>(
                value: selectedRelation,
                onChanged: (value) {
                  setState(() {
                    selectedRelation = value;
                  });
                },
                decoration: const InputDecoration(
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

              const SizedBox(height: 15), // 로그인 버튼과 텍스트 사이에 여백 추가


              ElevatedButton(
                onPressed: enroll, // 버튼 클릭 시 할 작업
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 버튼 색상 파란색
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 네모 모양으로 설정
                  ),
                  minimumSize: const Size(130, 50), // 버튼 크기 지정
                ),
                child: const Text(
                  "환자등록",
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