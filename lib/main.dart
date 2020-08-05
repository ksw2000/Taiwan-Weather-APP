import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import './weather.dart' as weather;
import './time.dart' as time;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '台中天氣'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    refreshWeather();
    int counter = 0;
    // Update every 1min for current weather
    Timer.periodic(Duration(seconds: 60), (timer) {
      // Update every 30 min for forecast weather
      if (counter % 30 == 0) {
        refreshForecastWeather();
      }
      refreshCurrentWeather();
      print('refresh');

      counter++;
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
  String curWeather = '...';
  String curWeatherCode = 'wi-na';

  void refreshForecastWeather() {
    weather.getForecastWeather('臺中市').then((map) {
      if (map != null) {
        setState(() {
          for (var i = 0; i < 3; i++) {
            startTime[i] = time.cwbDateFormatter(map[i]['startTime']);
            endTime[i] = time.cwbDateFormatter(map[i]['endTime']);
            wx[i] = map[i]['Wx']['parameterName'];
            weatherCode[i] =
                weather.cwbWxCodeToIconCode(map[i]['Wx']['parameterValue'], map[i]['startTime']);
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

  void refreshCurrentWeather() {
    weather.getCurrentWeather('臺中').then((map) {
      if (map != null) {
        setState(() {
          curTEMP = map['TEMP'];
          curHUMD = map['HUMD'];
          curWeather = map['Weather'];
          curWeather = curWeather == '-99'? '-' : curWeather;
          curWeatherCode = weather.cwdCurrentWeatherToIconCode(curWeather);
        });
      }
    });
  }

  void refreshWeather() {
    refreshCurrentWeather();
    refreshForecastWeather();
  }

  @override
  Widget build(BuildContext context) {
    var forecastChildren = <Widget>[];
    for (var i = 0; i < 3; i++) {
      forecastChildren.add(Text(
        '${startTime[i]} ~ ${endTime[i]}',
        style: TextStyle(fontSize: 21),
      ));
      forecastChildren.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              BoxedIcon(
                WeatherIcons.fromString(weatherCode[i]),
                size: 42,
              ),
              /*
              Text(
                "${wx[i]}",
                style: TextStyle(fontSize: 21),
              ),*/
            ],
          ),
          Column(
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
        ],
      ));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
              onPressed: refreshWeather, child: Icon(Icons.refresh)),
          appBar: AppBar(
            title: Text(widget.title),
            bottom: TabBar(tabs: [
              Tab(
                text: '現在',
              ),
              Tab(
                text: '預報',
              )
            ]),
          ),
          body: TabBarView(children: [
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
                  '溼度：${(double.parse(curHUMD) * 100).round()} %',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: forecastChildren)
          ]),
          drawer: Drawer(
              child: ListView(children: <Widget>[
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Item1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ]))),
    );
  }
}
