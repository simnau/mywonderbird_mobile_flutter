import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/models/spot-stats.dart';
import 'package:mywonderbird/models/stats.dart';
import 'package:mywonderbird/models/trip-stats.dart';

enum CountryStatsType {
  SPOT,
  TRIP,
}

class CountryStats<T extends IStats> {
  final CountryStatsType type;
  final T item;

  CountryStats({
    @required this.item,
    @required this.type,
  });

  factory CountryStats.fromJson(Map<String, dynamic> json) {
    final type = EnumToString.fromString(CountryStatsType.values, json['type']);

    if (type == CountryStatsType.SPOT) {
      return CountryStats<T>(
        item: SpotStats.fromJson(json['item']) as T,
        type: type,
      );
    }

    if (type == CountryStatsType.TRIP) {
      return CountryStats<T>(
        item: TripStats.fromJson(json['item']) as T,
        type: type,
      );
    }

    return null;
  }
}
