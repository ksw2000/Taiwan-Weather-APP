import 'package:flutter/material.dart';
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
  _MySettingPage(){
    //TODO
    //Test GPS

  }

  @override
  Widget build(BuildContext context) {
    loc.getPosition().then((position){
      loc.getStationWithGPS(position.latitude, position.longitude).then((city){
        print(city);
      });
    });

    return Center(
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('重新定位')
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