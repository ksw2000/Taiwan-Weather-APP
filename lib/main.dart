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
        child: MyHomePage(title: '台灣天氣'),
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

class Pages{
  dynamic page;
  dynamic tabBar;
  dynamic pages = {
    "indexPage": IndexPage(),
    "settingPage": SettingPage(),
    "chooseStation": ChooseStation()
  };

  dynamic tabBars = {
    "indexPage" : TabBar(tabs: [
      Tab(
        text: '現在',
      ),
      Tab(
        text: '預報',
      )
    ]),
    "settingPage" : null,
    "chooseStation": null
  };

  void changePage(String pageName){
    page = pages[pageName];
    tabBar = tabBars[pageName];
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Pages p = Pages();
  _MyHomePageState(){
    p.changePage('indexPage');
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
                  p.changePage('indexPage');
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('設定'),
              onTap: () {
                setState(() {
                  p.changePage('settingPage');
                });
                Navigator.pop(context);
              },
            ),
          ])
      ),
      appBar: AppBar(
        title: Text(widget.title),
        bottom: p.tabBar,
      ),
      body: p.page
    );
  }
}