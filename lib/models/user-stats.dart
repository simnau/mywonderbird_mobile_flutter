import 'package:flutter/material.dart';
import 'package:mywonderbird/models/country-geo-stats.dart';
import 'package:mywonderbird/models/spot.dart';
import 'package:mywonderbird/models/trip-stats.dart';

class UserStats {
  final List<String> visitedCountryCodes;
  final List<CountryGeoStats> visitedCountries;
  final int tripCount;
  final int plannedTripCount;
  final int spotCount;
  final TripStats currentTrip;
  final TripStats upcomingTrip;
  final TripStats lastTrip;
  final List<Spot> spots;

  UserStats({
    @required this.visitedCountryCodes,
    @required this.visitedCountries,
    @required this.tripCount,
    @required this.plannedTripCount,
    @required this.spotCount,
    @required this.currentTrip,
    @required this.upcomingTrip,
    @required this.lastTrip,
    @required this.spots,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      visitedCountryCodes: json['visitedCountryCodes'] != null
          ? json['visitedCountryCodes']
              .map<String>((countryCode) => countryCode.toString())
              .toList()
          : [],
      visitedCountries: json['visitedCountries'] != null
          ? json['visitedCountries']
              .map<CountryGeoStats>(
                  (visitedCountry) => CountryGeoStats.fromJson(visitedCountry))
              .toList()
          : null,
      tripCount: json['tripCount'],
      plannedTripCount: json['plannedTripCount'],
      spotCount: json['spotCount'],
      currentTrip: json['currentTrip'] != null
          ? TripStats.fromJson(json['currentTrip'])
          : null,
      upcomingTrip: json['upcomingTrip'] != null
          ? TripStats.fromJson(json['upcomingTrip'])
          : null,
      lastTrip: json['lastTrip'] != null
          ? TripStats.fromJson(json['lastTrip'])
          : null,
      spots:
          json['spots']?.map<Spot>((spot) => Spot.fromJson(spot))?.toList() ??
              [],
    );
  }
}
