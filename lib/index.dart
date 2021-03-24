import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taiwan_weather/err.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:sprintf/sprintf.dart';
import './err.dart' as err;
import './location.dart' as loc;
import './time.dart' as time;
import './weather.dart' as wea;

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  List<String> startTime = ['', '', ''];
  List<String> endTime = ['', '', ''];
  List<String> wx = ['', '', ''];
  List<String> minT = ['0', '0', '0'];
  List<String> maxT = ['0', '0', '0'];
  List<String> pop = ['0', '0', '0'];
  List<String> weatherCode = ['wi-na', 'wi-na', 'wi-na'];

  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      NowPage(),
      ForecastPage(),
    ]);
  }
}

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
    return wea
        .getCurrentWeather((await loc.getStationAndCity()).station)
        .then((map) {
      print("line55");
      if (map != null) {
        temp = sprintf("%.1f", [double.parse(map['TEMP'])]);
        humd = map['HUMD'];
        // 中央氣象局有時會出錯噴 -99
        // 這時可以保留原值或採用離預報最近的值
        if (map['Weather'] != '-99') {
          print("line62");
          weather = map['Weather'];
          code = wea.cwdCurrentWeatherToIconCode(weather);
          return WeatherCurrentInfo(
              temp: temp, humd: humd, weather: weather, code: code);
        }
      }

      return WeatherCurrentInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getCurrentWeather(),
        builder: (context, snapshot) {
          Widget wid;
          if (snapshot.hasError) {
            wid = err.ErrorMonkey('Something wrong');
          } else if (snapshot.hasData) {
            wid = Column(
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
                ]);
          } else {
            wid = CircularProgressIndicator();
          }
          return Center(child: wid);
        });
  }
}

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
    return wea
        .getForecastWeather((await loc.getStationAndCity()).city)
        .then((map) {
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
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getForecastWeather(),
        builder: (context, snapshot) {
          Widget w;
          if (snapshot.hasError) {
            w = ErrorMonkey(Err.apiErr);
          } else if (snapshot.hasData) {
            List<Widget> forecastElementList = [];
            snapshot.data?.forEach((e) {
              forecastElementList.add(ForecastElement(e));
            });

            w = Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: forecastElementList,
                )));
          } else {
            w = Center(child: CircularProgressIndicator());
          }
          return w;
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
