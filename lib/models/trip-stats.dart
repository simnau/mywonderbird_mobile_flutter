import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/types/named-item.dart';

import 'distance.dart';

enum TripType { SHARED_TRIP, SAVED_TRIP }

class TripStats extends NamedItem {
  final String id;
  final int spotCount;
  final int currentStep;
  final Distance distance;
  final String imageUrl;
  final String country;
  final String countryCode;
  final TripType tripType;

  TripStats({
    @required this.id,
    @required this.spotCount,
    @required this.currentStep,
    @required this.imageUrl,
    @required this.distance,
    @required this.country,
    @required this.countryCode,
    @required String name,
    @required this.tripType,
  }) : super(name: name);

  factory TripStats.fromJson(Map<String, dynamic> json) {
    return TripStats(
      id: json['id'],
      name: json['name'],
      spotCount: json['spotCount'],
      currentStep: json['currentStep'],
      imageUrl: json['imageUrl'],
      distance:
          json['distance'] != null ? Distance.fromJson(json['distance']) : null,
      country: json['country'],
      countryCode: json['countryCode'],
      tripType: EnumToString.fromString(TripType.values, json['tripType']),
    );
  }
}
