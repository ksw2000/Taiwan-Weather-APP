import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './err.dart';

class Location {
  Location({required this.city, required this.stationList});
  final String city;
  final List<String> stationList;
}

class Station {
  Station({required this.station, required this.distance});
  String station;
  double distance;
}

// 單點坐標回傳行政區
// https://data.gov.tw/dataset/101898

Future<Position> _getPosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('請允許定位');
    }

    if (permission == LocationPermission.denied) {
      return Future.error('請允許定位');
    }
  }
  return Future.value(await Geolocator.getCurrentPosition());
}

Future<List<String>> _getStationListByGPS(Position position) async {
  var lon = position.longitude;
  var lat = position.latitude;
  var ret = "";

  var rawData = await rootBundle.loadString('assets/json/station.json');
  var data = jsonDecode(rawData);

  // 距離由小到大排序
  List<Station> stationList = [];

  for (var i = 0; i < data.length; i++) {
    var _lat = num.parse(data[i]["lat"]);
    var _lon = num.parse(data[i]["lon"]);
    var _dis = (lat - _lat) * (lat - _lat) + (lon - _lon) * (lon - _lon);
    stationList.add(Station(station: data[i]["locationName"], distance: _dis));
  }

  stationList.sort((a, b) {
    return (a.distance > b.distance) ? 1 : -1;
  });

  List<String> stationStringList = [];

  stationList.forEach((element) {
    stationStringList.add(element.station);
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList("stations", stationStringList);

  print("getStationWithGPS() $ret");
  return stationStringList;
}

Future<String> _getCityWithGPS(Position position) async {
  var lat = position.latitude;
  var lon = position.longitude;

  // sometimes nlcs server will return 500
  for (int i = 0; i < 5; i++) {
    var res = await http.get(
        Uri.https('api.nlsc.gov.tw', '/other/TownVillagePointQuery/$lon/$lat'));
    print(Uri.https('api.nlsc.gov.tw', '/other/TownVillagePointQuery/$lon/$lat')
        .toString());

    if (res.statusCode == 200) {
      // The raw data is Big5
      var data = Utf8Decoder().convert(res.bodyBytes);
      String city =
          RegExp("<ctyName>(.*?)</ctyName>").firstMatch(data)!.group(1)!;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("city", city);
      return city;
    }
  }

  throw ErrorNLCSAPIError();
}

Future<Location> getStationAndCity() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? city = prefs.getString("city");
  List<String>? stationStringList = prefs.getStringList("stations");

  if (city != null && stationStringList != null) {
    // use cache
    return Location(
      city: city,
      stationList: stationStringList,
    );
  }

  // no cache, get city and station
  return _getPosition().then((position) async {
    city = await _getCityWithGPS(position);
    List<String> stationList = await _getStationListByGPS(position);
    return Future.value(Location(
      city: city ?? "",
      stationList: stationList,
    ));
  });
}
