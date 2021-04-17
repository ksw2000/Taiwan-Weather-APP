import 'package:flutter/material.dart';

class Error extends StatelessWidget {
  const Error(this.showText);
  final String showText;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(Icons.warning, size: 140),
                  SizedBox(height: 20),
                  Text(showText, style: TextStyle(fontSize: 17)),
                ])));
  }
}

class NetworkError implements Exception {
  NetworkError(this.statusCode);
  final int statusCode;
  String errMsg() => 'NetworkError: $statusCode';
}

class CWBAPIError implements Exception {
  String errMsg() => '中央氣象局 API 錯誤';
}

class NLCSAPIError implements Exception {
  String erMsg() => '國土測繪圖資服務雲 API 錯誤';
}
