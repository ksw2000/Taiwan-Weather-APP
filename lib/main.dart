import 'package:flutter/material.dart';
import 'page/now_page.dart';
import 'page/forecast_page.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Taiwan Weather',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Home(title: '台灣天氣'));
  }
}

class Home extends StatefulWidget {
  Home({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.title ?? ''),
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
                  NowPage(),
                  ForecastPage(),
                ]))));
  }
}
