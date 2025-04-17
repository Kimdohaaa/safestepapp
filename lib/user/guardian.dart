import 'package:flutter/material.dart';

class Guardian extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _GuardianState();
  }
}

class _GuardianState extends State<Guardian>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보호자화면"),),
    );
  }
}
