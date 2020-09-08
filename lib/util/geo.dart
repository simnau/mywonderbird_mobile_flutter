import 'package:exif/exif.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double ratioToDouble(Ratio ratio) {
  return ratio.numerator / ratio.denominator;
}

double dmsRatioToDouble(List<dynamic> dms) {
  if (dms.isEmpty || dms.length < 3) {
    return null;
  }

  final degreesRatio = dms[0] as Ratio;
  final minutesRatio = dms[1] as Ratio;
  final secondsRatio = dms[2] as Ratio;

  double degrees = degreesRatio.numerator / degreesRatio.denominator;
  double minutes = minutesRatio.numerator / minutesRatio.denominator;
  double seconds = secondsRatio.numerator / secondsRatio.denominator;

  return dmsToDouble(degrees, minutes, seconds);
}

double dmsToDouble(double degrees, double minutes, double seconds) {
  return degrees + minutes / 60 + seconds / 3600;
}

bool isNegativeRef(String gpsRef) {
  switch (gpsRef) {
    case 'N':
    case 'E':
      return false;
    case 'S':
    case 'W':
      return true;
    default:
      return false;
  }
}

LatLngBounds boundsFromLatLngList(List<LatLng> list) {
  double x0, x1, y0, y1;

  for (LatLng latLng in list) {
    if (x0 == null) {
      x0 = x1 = latLng.latitude;
      y0 = y1 = latLng.longitude;
    } else {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
  }
  return LatLngBounds(
    northeast: LatLng(x1, y1),
    southwest: LatLng(x0, y0),
  );
}
