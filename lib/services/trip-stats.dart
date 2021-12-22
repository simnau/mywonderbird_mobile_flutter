import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/services/api.dart';

const ROOT_PATH = '/api/trip-stats';

const CURRENT_TRIP_STATS_PATH = '$ROOT_PATH/current';
final currentTripStatsByUserIdPath =
    (String userId) => '$CURRENT_TRIP_STATS_PATH/$userId';

const UPCOMING_TRIP_STATS_PATH = '$ROOT_PATH/upcoming';
final upcomingTripStatsByUserIdPath =
    (String userId) => '$UPCOMING_TRIP_STATS_PATH/$userId';

const TRIP_STATS_PATH = ROOT_PATH;
final tripStatsByUserIdPath = (String userId) => '$TRIP_STATS_PATH/$userId';

class TripStatsService {
  final API api;

  TripStatsService({
    @required this.api,
  });

  Future<List<TripStats>> findMyCurrentTrips() async {
    final response = await api.get(CURRENT_TRIP_STATS_PATH);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching current trips. Please try again later',
      );
    }

    final trips = response['body']['trips']
        .map<TripStats>((tripStats) => TripStats.fromJson(tripStats))
        .toList();

    return trips;
  }

  Future<List<TripStats>> findCurrenTripsByUserId(String userId) async {
    final response = await api.get(currentTripStatsByUserIdPath(userId));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching current trips. Please try again later',
      );
    }

    final trips = response['body']['trips']
        .map<TripStats>((tripStats) => TripStats.fromJson(tripStats))
        .toList();

    return trips;
  }

  Future<List<TripStats>> findMyPlannedTrips() async {
    final response = await api.get(UPCOMING_TRIP_STATS_PATH);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching planned trips. Please try again later',
      );
    }

    final trips = response['body']['trips']
        .map<TripStats>((tripStats) => TripStats.fromJson(tripStats))
        .toList();

    return trips;
  }

  Future<List<TripStats>> findPlannedTripsByUserId(String userId) async {
    final response = await api.get(upcomingTripStatsByUserIdPath(userId));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching planned trips. Please try again later',
      );
    }

    final trips = response['body']['trips']
        .map<TripStats>((tripStats) => TripStats.fromJson(tripStats))
        .toList();

    return trips;
  }

  Future<List<TripStats>> findMyTrips() async {
    final response = await api.get(TRIP_STATS_PATH);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching trips. Please try again later',
      );
    }

    final trips = response['body']['trips']
        .map<TripStats>((tripStats) => TripStats.fromJson(tripStats))
        .toList();

    return trips;
  }

  Future<List<TripStats>> findTripsByUserId(String userId) async {
    final response = await api.get(tripStatsByUserIdPath(userId));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error fetching trips. Please try again later',
      );
    }

    final trips = response['body']['trips']
        .map<TripStats>((tripStats) => TripStats.fromJson(tripStats))
        .toList();

    return trips;
  }
}
