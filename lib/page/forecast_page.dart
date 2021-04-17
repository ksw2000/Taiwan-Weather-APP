import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taiwan_weather/err.dart';
import 'package:weather_icons/weather_icons.dart';
import '../location.dart' as loc;
import '../time.dart' as time;
import '../weather.dart' as wea;

class WeatherForecastInfo {
  WeatherForecastInfo(
      {@required this.start,
      @required this.end,
      this.wx = '',
      this.code = 'wi-na',
      this.minT = '0',
      this.maxT = '0',
      this.pop = '0'});
  final String start;
  final String end;
  final String wx;
  final String code;
  final String minT;
  final String maxT;
  final String pop;
}

class ForecastPage extends StatefulWidget {
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  Future<List<WeatherForecastInfo>> _getForecastWeather() async {
    List<WeatherForecastInfo> list = [];
    return loc.getStationAndCity().then((current) {
      return wea.getForecastWeather(current.city).then((map) {
        map.forEach((e) {
          list.add(WeatherForecastInfo(
            start: time.cwbDateFormatter(e['startTime']),
            end: time.cwbDateFormatter(e['endTime']),
            wx: e['Wx']['parameterName'],
            code: wea.cwbWxCodeToIconCode(
                e['Wx']['parameterValue'], e['startTime']),
            minT: e['MinT']['parameterName'],
            maxT: e['MaxT']['parameterName'],
            pop: e['PoP']['parameterName'],
          ));
        });
        return list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getForecastWeather(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Error(snapshot.error.toString());
          } else if (snapshot.hasData) {
            List<Widget> forecastElementList = [];
            snapshot.data?.forEach((e) {
              forecastElementList.add(ForecastElement(e));
            });

            return Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: forecastElementList,
                )));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

class ForecastElement extends StatelessWidget {
  ForecastElement(this.info);
  final WeatherForecastInfo info;
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Row(children: [
            BoxedIcon(
              WeatherIcons.fromString(info.code),
              size: 55,
            ),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${info.start} ~ ${info.end}',
                  style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                ),
                Text(
                  "${info.wx}",
                  style: TextStyle(fontSize: 25),
                ),
                Text(
                  "${info.minT}°C - ${info.maxT}°C 降雨率：${info.pop}%",
                  style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                ),
              ],
            ),
            Spacer(),
          ]),
        ));
  }
}
