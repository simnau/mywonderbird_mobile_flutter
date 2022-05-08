import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CountryGeoStats {
  final String countryCode;
  final String country;
  final LatLng center;
  final LatLng boundTopLeft;
  final LatLng boundBottomRight;

  CountryGeoStats({
    @required this.countryCode,
    @required this.country,
    @required this.center,
    @required this.boundTopLeft,
    @required this.boundBottomRight,
  });

  factory CountryGeoStats.fromJson(Map<String, dynamic> json) {
    return CountryGeoStats(
      countryCode: json['countryCode'],
      country: json['country'],
      center: json['center'] != null
          ? LatLng(
              json['center']['lat'] + 0.0,
              json['center']['lng'] + 0.0,
            )
          : null,
      boundTopLeft: json['boundaries'] != null
          ? LatLng(
              json['boundaries']['topLeft']['lat'] + 0.0,
              json['boundaries']['topLeft']['lng'] + 0.0,
            )
          : null,
      boundBottomRight: json['boundaries'] != null
          ? LatLng(
              json['boundaries']['bottomRight']['lat'] + 0.0,
              json['boundaries']['bottomRight']['lng'] + 0.0,
            )
          : null,
    );
  }
}
