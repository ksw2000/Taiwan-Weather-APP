import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Location {
  Location({this.city, this.station});
  final String city;
  final String station;
}

// 單點坐標回傳行政區
// https://data.gov.tw/dataset/101898

Future<Position> getLastKnownPosition() async {
  return await Geolocator()
      .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
}

Future<Position> getPosition() async {
  return await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

Future<String> getStationWithGPS(double lat, double lon) async {
  var minDistance = double.maxFinite;
  var ret = "";

  var rawData = await rootBundle.loadString('assets/json/station.json');
  var data = jsonDecode(rawData);
  for (var i = 0; i < data.length; i++) {
    var _lat = num.parse(data[i]["lat"]);
    var _lon = num.parse(data[i]["lon"]);
    var dis = (lat - _lat) * (lat - _lat) + (lon - _lon) * (lon - _lon);
    if (dis < minDistance) {
      minDistance = dis;
      ret = data[i]["locationName"];
    }
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("station", ret);

  print("getStationWithGPS() $ret");
  return ret;
}

Future<String> getCityWithGPS(double lat, double lon) async {
  print('https://api.nlsc.gov.tw/other/TownVillagePointQuery/$lon/$lat');
  var res = await http
      .get('https://api.nlsc.gov.tw/other/TownVillagePointQuery/$lon/$lat');

  if (res.statusCode == 200) {
    // The raw data is Big5
    var data = Utf8Decoder().convert(res.bodyBytes);
    RegExp exp = new RegExp("<ctyName>(.*?)</ctyName>");
    String city = exp.firstMatch(data).group(1);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("city", city);
    print("getCityWithGPS() $city");
    return city;
  }
  return "";
}

Future<List> loadAllStation() async {
  var ret = List();
  await rootBundle.loadString('assets/json/station.json').then((rawData) {
    var data = jsonDecode(rawData);
    for (var i = 0; i < data.length; i++) {
      ret.add(data[i]['locationName']);
    }
  });
  return ret;
}

Future<bool> isAutoRelocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // 預設是自動定位
  return prefs.get("autoRelocation") ?? true;
}

Future<bool> toggleAutoRelocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isAutoRelocation = prefs.get("autoRelocation") ?? true;
  if (isAutoRelocation) {
    prefs.setBool("autoRelocation", false);
    return false;
  }

  prefs.setBool("autoRelocation", true);
  return true;
}

Future<Location> getStationAndCity() async {
  bool autoRelocation = await isAutoRelocation();
  var prefs = await SharedPreferences.getInstance();
  var city = prefs.getString("city");
  var station = prefs.getString("station");

  if (city == '' || station == '' || autoRelocation) {
    // 沒有快取，重新取得城市及測站
    var position = await getPosition();
    station = await getStationWithGPS(position.latitude, position.longitude);
    city = await getCityWithGPS(position.latitude, position.longitude);
  }
  // 使用快取
  return Location(
    station: station,
    city: city,
  );
}
