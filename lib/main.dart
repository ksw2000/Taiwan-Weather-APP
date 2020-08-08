import 'package:flutter/material.dart';
import './index.dart';
import './setting.dart';

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
      home: DefaultTabController(
        length: 2,
        child: MyHomePage(title: '台中天氣'),
      )
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
  final pages = {
    "indexPage": IndexPage(),
    "settingPage": SettingPage()
  };

  final tabBars = {
    "indexPage" : TabBar(tabs: [
      Tab(
        text: '現在',
      ),
      Tab(
        text: '預報',
      )
    ]),
    "settingPage" : null
  };

  var page, tabBar;
  _MyHomePageState(){
    page = pages['indexPage'];
    tabBar = tabBars['indexPage'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView(children: <Widget>[
            ListTile(
              leading: Icon(Icons.home),
              title: Text('首頁'),
              onTap: () {
                setState(() {
                  page = pages["indexPage"];
                  tabBar = tabBars["indexPage"];
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('設定'),
              onTap: () {
                setState(() {
                  page = pages["settingPage"];
                  tabBar = tabBars["settingPage"];
                });
                Navigator.pop(context);
              },
            ),
          ])
      ),
      appBar: AppBar(
        title: Text(widget.title),
        bottom: tabBar,
      ),
      body: page
    );
  }
}