import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import '../err.dart';
import '../location.dart';
import '../weather.dart';

class WeatherCurrentInfo {
  WeatherCurrentInfo(
      {this.temp = 0,
      this.station = '',
      this.humd = 0,
      this.r24 = 0, //日累積雨量
      this.weather = '',
      this.code = 'wi-na'});
  final String station;
  final double temp;
  final double humd;
  final double r24;
  final String weather;
  final String code;
}

class NowPage extends StatefulWidget {
  _NowPageState createState() => _NowPageState();
}

class _NowPageState extends State<NowPage> {
  Future<WeatherCurrentInfo> _getCurrentWeather() async {
    Location current = await getStationAndCity();
    Map info = {};

    for (int i = 0; i < current.stationList.length; i++) {
      var station = current.stationList[i];
      info = await getCurrentWeather(station);
      print(info);
      if (info['Weather'] != '-99') {
        return Future.value(WeatherCurrentInfo(
            temp: double.parse(info['TEMP']),
            station: current.stationList[i],
            humd: double.parse(info['HUMD']),
            r24: double.parse(info['24R']),
            weather: info['Weather'],
            code: cwdCurrentWeatherToIconCode(info['Weather'])));
      }
    }

    return Future.value(WeatherCurrentInfo(
        temp: .0,
        station: current.stationList[0],
        humd: .0,
        r24: .0,
        weather: info['Weather'],
        code: cwdCurrentWeatherToIconCode(info['Weather'])));
  }

  ScrollController? scrollCtrl;
  @override
  void initState() {
    scrollCtrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scrollCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Error(snapshot.error.toString()));
          } else if (snapshot.hasData && snapshot.data != null) {
            dynamic data = snapshot.data;
            return Scrollbar(
                controller: scrollCtrl,
                isAlwaysShown: true,
                child: Center(
                    child: SingleChildScrollView(
                        controller: scrollCtrl,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BoxedIcon(
                                WeatherIcons.fromString(data.code),
                                size: 100,
                              ),
                              Text(
                                data.weather,
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                '溫度：${data.temp}°C',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '溼度：${(data.humd * 100).toStringAsFixed(1)} %',
                                style: TextStyle(fontSize: 20),
                              ),
                              (data.r24 != '0')
                                  ? Text(
                                      '累積雨量：${(data.r24).toStringAsFixed(1)} mm',
                                      style: TextStyle(fontSize: 20),
                                    )
                                  : Container(),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                '來自${data.station}測站',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ]))));
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
