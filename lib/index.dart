import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import './location.dart' as loc;
import './time.dart' as time;
import './weather.dart' as weather;

class IndexPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MyIndexPage();
  }
}

class MyIndexPage extends StatefulWidget {
  MyIndexPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyIndexPageState createState() => _MyIndexPageState();
}

class _MyIndexPageState extends State<MyIndexPage>{
  String currentCity;
  String currentStation;
  bool isAutoRelocation;
  _MyIndexPageState() {
    // 用用戶允許自動定位就刷新定位
    _refreshCurrentPositionIfUserAllow().then((_){
      print('$currentCity $currentStation');
      _refreshForecastWeather();
      _refreshCurrentWeather();

      int counter = 0;
      // Update every 1min for current weather
      Timer.periodic(Duration(seconds: 60), (timer) {
        if(this.mounted){
          _refreshCurrentPositionIfUserAllow().then((_) {
            // Update every 30 min for forecast weather
            if (counter % 30 == 0) {
              _refreshForecastWeather();
            }
            _refreshCurrentWeather();
            print('refresh');

            counter++;
          });
        }
      });
    });
  }

  List<String> startTime = ['', '', ''];
  List<String> endTime = ['', '', ''];
  List<String> wx = ['', '', ''];
  List<String> minT = ['0', '0', '0'];
  List<String> maxT = ['0', '0', '0'];
  List<String> pop = ['0', '0', '0'];
  List<String> weatherCode = ['wi-na', 'wi-na', 'wi-na'];
  String curTEMP = '0';
  String curHUMD = '0';
  String curWeather = '';
  String curWeatherCode = 'wi-na';

  Future<dynamic> _refreshCurrentPositionIfUserAllow() async{
    bool yesOrNo =  await loc.isAutoRelocation();
    isAutoRelocation = yesOrNo;

    if (isAutoRelocation) {
      // 無論如何更新 location 和 station
      print("用戶開啟自動定位，無論如何更新 location 和 station");
      var position = await loc.getPosition();
      currentStation = await loc.getStationWithGPS(position.latitude, position.longitude);
      currentCity = await loc.getCityWithGPS(position.latitude, position.longitude);
    } else {
      // 如果有上次的記錄就拿上次的記錄，若沒有則仍要求定位

      print("用戶關閉自動定位，拿取上次記錄");
      var prefs = await SharedPreferences.getInstance();
      // 先拿上次的
      currentCity = prefs.getString("city");
      currentStation = prefs.getString("station");
      // 如果沒有，就重新拿
      if (currentCity == '' || currentStation == '') {
        var position = await loc.getPosition();
        if(currentCity == ''){
          currentCity = await loc.getCityWithGPS(position.latitude, position.longitude);
        }

        if(currentStation == ''){
          currentStation = await loc.getStationWithGPS(position.latitude, position.longitude);
        }
      }
    }
  }

  Future<dynamic> _refreshForecastWeather() async {
    return weather.getForecastWeather(currentCity).then((map) {
      if (map != null) {
        setState(() {
          for (var i = 0; i < 3; i++) {
            startTime[i] = time.cwbDateFormatter(map[i]['startTime']);
            endTime[i] = time.cwbDateFormatter(map[i]['endTime']);
            wx[i] = map[i]['Wx']['parameterName'];
            weatherCode[i] = weather.cwbWxCodeToIconCode(
                map[i]['Wx']['parameterValue'], map[i]['startTime']);
            minT[i] = map[i]['MinT']['parameterName'];
            maxT[i] = map[i]['MaxT']['parameterName'];
            pop[i] = map[i]['PoP']['parameterName'];
          }
        });
      } else {
        // TODO
        print("result 0");
      }
    });
  }

  Future<dynamic> _refreshCurrentWeather() async {
    return weather.getCurrentWeather(currentStation).then((map) {
      if (map != null) {
        setState(() {
          curTEMP = sprintf("%.1f", [double.parse(map['TEMP'])]);
          curHUMD = map['HUMD'];
          // 中央氣象局有時會出錯噴 -99
          // 這時可以保留原值或採用離預報最近的值
          if(map['Weather'] != '-99'){
            curWeather = map['Weather'];
            curWeatherCode = weather.cwdCurrentWeatherToIconCode(curWeather);
          }else if(curWeather == ''){ // 仍為空值(調用預報值)
            _refreshForecastWeather().then((_){
              curWeather = wx[0];
              curWeatherCode = weatherCode[0];
            });
          }
        });
      }
    });
  }

  List forecastChildren(BuildContext context){
    var forecastChildrenList = <Widget>[];
    for (var i = 0; i < 3; i++) {
      forecastChildrenList.add(
          Center(
              child: Text(
                '${startTime[i]} ~ ${endTime[i]}',
                style: TextStyle(fontSize: 18, color: Colors.blueGrey),
              )
          )
      );
      forecastChildrenList.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: FlatButton(
                        child: BoxedIcon(
                          WeatherIcons.fromString(weatherCode[i]),
                          size: 42,
                        ),
                        onPressed: (){
                          Scaffold.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(wx[i])
                              )
                          );
                        },
                      )
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${minT[i]}°C ~ ${maxT[i]}°C",
                        style: TextStyle(fontSize: 21),
                      ),
                      Text(
                        "降雨率：${pop[i]}%",
                        style: TextStyle(fontSize: 21),
                      )
                    ],
                  ),
                ]
            ),
          )
      );
    }
    return forecastChildrenList;
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      RefreshIndicator(
          onRefresh: _refreshCurrentWeather,
          child: Container(
              alignment: Alignment.center,
              child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BoxedIcon(
                            WeatherIcons.fromString('$curWeatherCode'),
                            size: 100,
                          ),
                          Text(
                            curWeather,
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            '溫度：$curTEMP°C',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            '溼度：${(double.parse(curHUMD) * 100)
                                .round()} %',
                            style: TextStyle(fontSize: 20),
                          ),
                        ]
                    )
                  ]
              )
          )
      ),
      Builder(
          builder: (BuildContext context) {
            return RefreshIndicator(
                onRefresh: _refreshForecastWeather,
                child: Container(
                  alignment: Alignment.center,
                  height: double.infinity,
                  child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: forecastChildren(context)
                  ),
                )
            );
          }
      )
    ]);
  }
}