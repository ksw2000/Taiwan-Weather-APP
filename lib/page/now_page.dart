import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:sprintf/sprintf.dart';
import '../err.dart';
import '../location.dart' as loc;
import '../weather.dart' as wea;

class WeatherCurrentInfo {
  WeatherCurrentInfo(
      {this.temp = '0',
      this.humd = '0',
      this.weather = '',
      this.code = 'wi-na'});
  final String temp;
  final String humd;
  final String weather;
  final String code;
}

class NowPage extends StatefulWidget {
  _NowPageState createState() => _NowPageState();
}

class _NowPageState extends State<NowPage> {
  Future<WeatherCurrentInfo> _getCurrentWeather() async {
    String temp, humd, weather, code;
    return loc.getStationAndCity().then((current) {
      return wea.getCurrentWeather(current.station).then((map) {
        temp = sprintf("%.1f", [double.parse(map['TEMP'])]);
        humd = map['HUMD'];
        // 中央氣象局有時會出錯噴 -99
        // 這時可以保留原值或採用離預報最近的值
        if (map['Weather'] != '-99') {
          weather = map['Weather'];
          code = wea.cwdCurrentWeatherToIconCode(weather);
          print("weather $weather, code $code");
          return Future.value(WeatherCurrentInfo(
              temp: temp, humd: humd, weather: weather, code: code));
        }
        throw CWBAPIError();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Error(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            return Center(
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  BoxedIcon(
                    WeatherIcons.fromString(snapshot.data.code),
                    size: 100,
                  ),
                  Text(
                    snapshot.data.weather,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    '溫度：${snapshot.data.temp}°C',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    '溼度：${(double.parse(snapshot.data.humd) * 100).round()} %',
                    style: TextStyle(fontSize: 20),
                  ),
                ]));
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
