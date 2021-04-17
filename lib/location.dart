import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './err.dart';

class Location {
  Location({this.city, this.station});
  final String city;
  final String station;
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

Future<String> getStationWithGPS(Position position) async {
  var lon = position.longitude;
  var lat = position.latitude;
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

Future<String> getCityWithGPS(Position position) async {
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
      RegExp exp = new RegExp("<ctyName>(.*?)</ctyName>");
      String city = exp.firstMatch(data).group(1);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("city", city);
      return city;
    }
  }

  throw NLCSAPIError();
}

Future<Location> getStationAndCity() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var city = prefs.getString("city");
  var station = prefs.getString("station");

  if (city != '' && station != '') {
    // use cache
    return Location(
      station: station,
      city: city,
    );
  }

  // no cache, get city and station
  return _getPosition().then((position) async {
    station = await getStationWithGPS(position);
    try {
      city = await getCityWithGPS(position);
      return Future.value(Location(
        station: station,
        city: city,
      ));
    } catch (e) {
      throw e;
    }
  });
}
