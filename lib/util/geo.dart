import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
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
  double lat0, lat1, lng0, lng1;

  for (LatLng latLng in list) {
    if (lat0 == null) {
      lat0 = lat1 = latLng.latitude;
      lng0 = lng1 = latLng.longitude;
    } else {
      if (latLng.latitude > lat1) lat1 = latLng.latitude;
      if (latLng.latitude < lat0) lat0 = latLng.latitude;
      if (latLng.longitude > lng1) lng1 = latLng.longitude;
      if (latLng.longitude < lng0) lng0 = latLng.longitude;
    }
  }
  return LatLngBounds(
    northeast: LatLng(lat1, lng1),
    southwest: LatLng(lat0, lng0),
  );
}

LatLng boundsCenter(LatLngBounds bounds) {
  if (bounds == null) {
    return null;
  }

  double latCenter =
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
  double lngCenter =
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2;

  return LatLng(latCenter, lngCenter);
}

LatLngBounds getBounds(
  LatLng center,
  double zoom,
  double width,
  double height,
) {
  var _correctZoom = math.pow(2, zoom) * 2;
  var _width = width.toInt() / _correctZoom;
  var _height = height.toInt() / _correctZoom;

  double latSouth = center.latitude - _height;
  double latNorth = center.latitude + _height;
  double lngWest = center.longitude - _width;
  double lngEast = center.longitude + _width;

  return LatLngBounds(
    southwest: LatLng(latSouth, lngWest),
    northeast: LatLng(latNorth, lngEast),
  );
}

num getDistanceInKilometers(
  LatLng start,
  LatLng end, {
  bool round = true,
}) {
  if (start == null || end == null) {
    return null;
  }

  final distanceInMeters = Geolocator.distanceBetween(
    start.latitude,
    start.longitude,
    end.latitude,
    end.longitude,
  );

  double distanceInKilometers = distanceInMeters / 1000;

  return distanceInKilometers;
}

double getBearing(
  LatLng start,
  LatLng end,
) {
  if (start == null || end == null) {
    return null;
  }

  final bearing = Geolocator.bearingBetween(
    start.latitude,
    start.longitude,
    end.latitude,
    end.longitude,
  );

  return bearing;
}
