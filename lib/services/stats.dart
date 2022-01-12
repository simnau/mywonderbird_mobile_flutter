import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/models/user-stats.dart';

import 'api.dart';

const USER_STATS_PATH = '/api/stats/user';
final userStatsByIdPath = (String userId) => '/api/stats/user/$userId';

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
        'There was an error sharing the picture. Please try again later',
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
        'There was an error sharing the picture. Please try again later',
      );
    }

    final stats = UserStats.fromJson(response['body']);

    return stats;
  }
}
