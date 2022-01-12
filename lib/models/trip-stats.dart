import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/types/named-item.dart';

import 'distance.dart';

enum TripType { SHARED_TRIP, SAVED_TRIP }

enum TripStatus { PLANNED, IN_PROGRESS, FINISHED }

class TripStats extends NamedItem {
  final String id;
  final int spotCount;
  final int currentStep;
  final Distance distance;
  final String imageUrl;
  final String country;
  final String countryCode;
  final TripType tripType;
  final TripStatus tripStatus;

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
    @required this.tripStatus,
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
      tripType: json['tripType'] != null
          ? EnumToString.fromString(TripType.values, json['tripType'])
          : null,
      tripStatus: json['tripStatus'] != null
          ? EnumToString.fromString(TripStatus.values, json['tripStatus'])
          : null,
    );
  }
}
