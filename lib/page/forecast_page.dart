import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taiwan_weather/err.dart';
import 'package:weather_icons/weather_icons.dart';
import '../location.dart';
import '../weather.dart';

class WeatherForecastInfo {
  WeatherForecastInfo(
      {required this.start,
      required this.end,
      this.wx = '', // 天氣型態
      this.wx2 = '', // 比較簡短的天氣型態
      this.code = 'wi-na', // weather icon
      this.minT = 0,
      this.maxT = 0,
      this.pop = 0});
  final String start;
  final String end;
  final String wx;
  final String wx2;
  final String code;
  final double minT;
  final double maxT;
  final double pop;
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
            forecastElementList.add(SizedBox(
              height: 10,
            ));
            data["infoList"].forEach((e) {
              forecastElementList.add(ForecastElement(e));
            });

            forecastElementList.addAll([
              SizedBox(height: 10),
              Text(
                "來自${data["city"]}測站",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              )
            ]);

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

  Future<Map> _getForecastWeather() async {
    List<WeatherForecastInfo> list = [];
    return getStationAndCity().then((current) {
      return getForecastWeather(current.city).then((map) {
        map.forEach((e) {
          list.add(WeatherForecastInfo(
            start: _cwbDateFormatter(e['startTime']),
            end: _cwbDateFormatter(e['endTime']),
            wx: e['Wx']['parameterName'],
            wx2: cwbWxCodeToWeather(e['Wx']['parameterValue']),
            code:
                cwbWxCodeToIconCode(e['Wx']['parameterValue'], e['startTime']),
            minT: double.parse(e['MinT']['parameterName']),
            maxT: double.parse(e['MaxT']['parameterName']),
            pop: double.parse(e['PoP']['parameterName']),
          ));
        });
        return {"city": current.city, "infoList": list};
      });
    });
  }

  String _cwbDateFormatter(String date) {
    var t = DateTime.parse(date);
    var ret = t.month.toString().padLeft(2, "0");
    ret += '/';
    ret += t.day.toString().padLeft(2, "0");
    ret += ' ';
    ret += t.hour.toString().padLeft(2, "0");
    ret += ':';
    ret += t.minute.toString().padLeft(2, "0");
    return ret;
  }
}

class ForecastElement extends StatelessWidget {
  ForecastElement(this.info);
  final WeatherForecastInfo info;
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 12,
        child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Row(children: [
                BoxedIcon(
                  WeatherIcons.fromString(info.code),
                  size: 55,
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      '${info.start} ~ ${info.end}',
                      style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                    ),
                    Text(
                      "${info.wx2}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "${info.minT}°C - ${info.maxT}°C 降雨率：${info.pop}%",
                      style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                    ),
                  ],
                ),
                Spacer(),
              ]),
            )));
  }
}
