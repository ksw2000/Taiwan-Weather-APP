import 'package:flutter/material.dart';

class Err {
  static const String apiErr = '後端 API 崩潰';
  static const String nil = '';
}

class ErrorMonkey extends StatelessWidget {
  const ErrorMonkey(this.show);
  final String show;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
          Text('🙈', style: TextStyle(fontSize: 140)),
          SizedBox(height: 20),
          Text(show, style: TextStyle(fontSize: 25)),
        ]));
  }
}
