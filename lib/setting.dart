import 'dart:async' show Future;
import 'package:flutter/material.dart';
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
  var currentCity = "loading...";
  var currentStation = "loading...";
  var autoRelocation = "loading...";

  _MySettingPage(){
    // 初次載入時載入上次的 city 及上次的 station
    _loadCurrentPosition();
    // 載入是否啟用自動定位
    _loadIsAutoRelocation();
  }

  Future<void> _relocate() async{
    var position = await loc.getPosition();
    currentStation = await loc.getStationWithGPS(position.latitude, position.longitude);
    currentStation = await loc.getCityWithGPS(position.latitude, position.longitude);
  }

  Future<void> _loadCurrentPosition() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentCity = prefs.get("city");
      currentStation = prefs.get("station");
    });
    print('debug: $currentCity , $currentStation');
  }

  Future<void> _loadIsAutoRelocation([bool yesOrNo]) async{
    if(yesOrNo == null){
      await loc.isAutoRelocation().then((getYesOrNo){
        yesOrNo = getYesOrNo;
      });
    }

    setState(() {
      autoRelocation = (yesOrNo) ? "每次皆重新定位" : "依照上次儲存的定位";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: <Widget>[
          ListTile(
              leading: Icon(Icons.near_me),
              title: Text('自動重新定位'),
              subtitle: Text(
                  '$autoRelocation'
              ),
              onTap: (){
                loc.toggleAutoRelocation().then((yesOrNo){
                  _loadIsAutoRelocation(yesOrNo);
                });
              }
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('GPS 重新定位'),
            subtitle: Text(
                "$currentCity, $currentStation測站"
            ),
            onTap: (){
              _relocate().then((_){
                _loadCurrentPosition().then((_){
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
            title: Text('手動選擇地區'),
            subtitle: Text('自動定位：'),
            onTap: () {
              setState(() {
                //TODO
                //切換頁面
                print("切換到選擇地區頁");
              });
              Navigator.pop(context);
            },
          ),
        ]
      )
    );
  }
}

class ChooseStation extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MyChooseStation();
  }
}

class MyChooseStation extends StatefulWidget{
  MyChooseStation({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyChooseStation createState() => _MyChooseStation();
}

class _MyChooseStation extends State<MyChooseStation>{
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile (title: Text('1')),
        ListTile (title: Text('2')),
        ListTile (title: Text('3')),
      ],
    );
  }
}