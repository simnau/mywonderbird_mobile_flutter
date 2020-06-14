import 'package:exif/exif.dart';

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
