import 'package:flutter/material.dart';
import 'package:mywonderbird/models/saved-trip-location.dart';
import 'package:mywonderbird/util/json.dart';

class SavedTrip {
  final String title;
  final String countryCode;
  final List<SavedTripLocation> savedTripLocations;

  SavedTrip({
    @required this.title,
    @required this.countryCode,
    @required this.savedTripLocations,
  });

  Map<String, dynamic> toJson() {
    return removeNulls({
      'title': title,
      'countryCode': countryCode,
      'savedTripLocations': savedTripLocations.map((e) => e.toJson()).toList(),
    });
  }
}
