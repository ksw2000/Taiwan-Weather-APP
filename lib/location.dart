import 'package:geolocator/geolocator.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' as convert;

Future<Position> getPosition() async{
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return position;
}

Future<String> getStationWithGPS(double lat, double lon) async{
  var minDistance = double.maxFinite;
  var minCityName = "";

  await rootBundle.loadString('assets/json/city.json').then((rawData){
    var data = convert.jsonDecode(rawData);

    for(var i=0; i<data.length; i++){
      var _lat = num.parse(data[i]["lat"]);
      var _lon = num.parse(data[i]["lon"]);
      var dis = (lat - _lat)*(lat - _lat) + (lon-_lon)*(lon-_lon);
      if(dis < minDistance){
        minDistance = dis;
        minCityName = data[i]["locationName"];
      }
    }
  });

  return minCityName;
}