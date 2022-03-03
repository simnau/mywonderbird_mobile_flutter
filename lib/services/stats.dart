import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/models/country-stats.dart';
import 'package:mywonderbird/models/user-stats.dart';

import 'api.dart';

const USER_STATS_PATH = '/api/stats/user';
final userStatsByIdPath = (String userId) => '$USER_STATS_PATH/$userId';
const COUNTRY_STATS_PATH = '/api/stats/country';
final countryStatsByIdPath = (String userId) => '$COUNTRY_STATS_PATH/$userId';

class StatsService {
  final API api;

  StatsService({
    @required this.api,
  });

  Future<UserStats> fetchCurrentUserStats() async {
    final response = await api.get(USER_STATS_PATH);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching the user stats. Please try again later',
      );
    }

    final stats = UserStats.fromJson(response['body']);

    return stats;
  }

  Future<UserStats> fetchUserStats(String userId) async {
    final response = await api.get(userStatsByIdPath(userId));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching the user stats. Please try again later',
      );
    }

    final stats = UserStats.fromJson(response['body']);

    return stats;
  }

  Future<List<CountryStats>> fetchCurrentUserCountryStats(
    String countryCode,
  ) async {
    final response = await api.get(COUNTRY_STATS_PATH, params: {
      'countryCode': countryCode,
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching the country stats. Please try again later',
      );
    }

    final stats = response['body']['stats'];

    return stats.map<CountryStats>((stats) {
      return CountryStats.fromJson(stats);
    }).toList();
  }

  Future<List<CountryStats>> fetchUserCountryStats(
    String userId,
    String countryCode,
  ) async {
    final response = await api.get(countryStatsByIdPath(userId), params: {
      'countryCode': countryCode,
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching the country stats. Please try again later',
      );
    }

    final stats = response['body']['stats'];

    return stats.map<CountryStats>((stats) {
      return CountryStats.fromJson(stats);
    }).toList();
  }
}
