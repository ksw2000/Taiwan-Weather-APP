import 'dart:async' show Future;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './location.dart' as loc;

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
  var currentCity = "";
  var currentStation = "";

  _MySettingPage(){
    // 初次載入時載入上次的 city 及上次的 station
    _refreshCurrentPosition();
  }

  Future<void> _relocate() async{
    var position = await loc.getPosition();
    currentStation = await loc.getStationWithGPS(position.latitude, position.longitude);
    currentStation = await loc.getCityWithGPS(position.latitude, position.longitude);
  }

  Future<void> _refreshCurrentPosition() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentCity = prefs.get("city");
      currentStation = prefs.get("station");
    });
    print('debug: $currentCity , $currentStation');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('重新定位'),
            subtitle: Text(
                "$currentCity, $currentStation測站"
            ),
            onTap: (){
              _relocate().then((_){
                _refreshCurrentPosition().then((_){
                  print("done");
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                        content: Text('已更新'),
                        duration: Duration(seconds:2)
                    )
                  );
                });
              });
            }
          ),
          ListTile(
              leading: Icon(Icons.location_searching),
              title: Text('選擇地區')
          ),
        ]
      )
    );
  }
}