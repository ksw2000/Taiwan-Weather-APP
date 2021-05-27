import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taiwan_weather/err.dart';
import 'package:weather_icons/weather_icons.dart';
import '../location.dart';
import '../time.dart';
import '../weather.dart';

class WeatherForecastInfo {
  WeatherForecastInfo(
      {required this.start,
      required this.end,
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
        future: _getForecastWeather(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Error(snapshot.error.toString());
          } else if (snapshot.hasData && snapshot.data != null) {
            dynamic data = snapshot.data;
            List<Widget> forecastElementList = [];
            data.forEach((e) {
              forecastElementList.add(ForecastElement(e));
            });

            return Scrollbar(
                isAlwaysShown: true,
                controller: scrollCtrl,
                child: SingleChildScrollView(
                    controller: scrollCtrl,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: forecastElementList,
                        ))));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<List<WeatherForecastInfo>> _getForecastWeather() async {
    List<WeatherForecastInfo> list = [];
    return getStationAndCity().then((current) {
      return getForecastWeather(current.city).then((map) {
        map.forEach((e) {
          list.add(WeatherForecastInfo(
            start: cwbDateFormatter(e['startTime']),
            end: cwbDateFormatter(e['endTime']),
            wx: e['Wx']['parameterName'],
            code:
                cwbWxCodeToIconCode(e['Wx']['parameterValue'], e['startTime']),
            minT: e['MinT']['parameterName'],
            maxT: e['MaxT']['parameterName'],
            pop: e['PoP']['parameterName'],
          ));
        });
        return list;
      });
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
