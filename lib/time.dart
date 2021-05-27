// convert YYYY-MM-DD hh:mm:ss
// to MM/DD hh:mm
import 'package:sprintf/sprintf.dart';

String cwbDateFormatter(String date) {
  var t = DateTime.parse(date);
  var ret = sprintf('%02i', [t.month]);
  ret += '/';
  ret += sprintf('%02i', [t.day]);
  ret += ' ';
  ret += sprintf('%02i', [t.hour]);
  ret += ':';
  ret += sprintf('%02i', [t.minute]);
  return ret;
}

bool isNight([String? t]) {
  int hour = t == null ? new DateTime.now().hour : DateTime.parse(t).hour;
  return hour < 6 || hour >= 18;
}
