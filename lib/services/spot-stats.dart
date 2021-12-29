import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/models/spot-stats.dart';
import 'package:mywonderbird/services/api.dart';

const SPOT_STATS_PATH = '/api/spot-stats';
final spotStatsByIdPath = (String userId) => '/api/spot-stats/$userId';

class SpotStatsService {
  final API api;

  SpotStatsService({
    @required this.api,
  });

  Future<List<SpotStats>> findMySpots() async {
    final response = await api.get(SPOT_STATS_PATH);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching the user spots. Please try again later',
      );
    }

    final spots = response['body']['spots']
        .map<SpotStats>((spot) => SpotStats.fromJson(spot))
        .toList();

    return spots;
  }

  Future<List<SpotStats>> findSpotsByUserId(String userId) async {
    final response = await api.get(spotStatsByIdPath(userId));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching the user spots. Please try again later',
      );
    }

    final spots = response['body']['spots']
        .map<SpotStats>((spot) => SpotStats.fromJson(spot))
        .toList();

    return spots;
  }
}
