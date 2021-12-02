import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/models/user-stats.dart';

import 'api.dart';

const USER_STATS_PATH = '/api/stats/user';

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
}
