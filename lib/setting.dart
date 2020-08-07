import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MySettingPage();
  }
}

class MySettingPage extends StatefulWidget {
  MySettingPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MySettingPage createState() => _MySettingPage();
}

class _MySettingPage extends State<MySettingPage>{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Setting page'
      ),
    );
  }
}