import 'package:flutter/material.dart';

class Patient extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _PatientState();
  }
}

class _PatientState extends State<Patient>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("환자페이지"),),
    );
  }
}