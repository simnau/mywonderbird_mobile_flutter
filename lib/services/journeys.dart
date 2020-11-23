import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/services/api.dart';

const CREATE_JOURNEY_PATH = '/api/journeys';
const MY_JOURNEYS_PATH = '/api/journeys/v2/my';
const LAST_JOURNEY_PATH = '/api/journeys/last';
final getJourneyPath = (journeyId) => "/api/journeys/v2/$journeyId";

class JourneyService {
  final API api;

  JourneyService({@required this.api});

  Future<List<Journey>> allForUser() async {
    final response = await api.get(MY_JOURNEYS_PATH);
    final journeysRaw = response['body']['journeys'];

    final journeys = journeysRaw
        .map<Journey>((journey) => Journey.fromRequestJson(journey))
        .toList();

    return journeys;
  }

  Future<Journey> createJourney(Journey journey) async {
    final response = await api.post(CREATE_JOURNEY_PATH, journey.toJson());
    final journeyRaw = response['body'];
    final savedJourney = Journey.fromRequestJson(journeyRaw);

    return savedJourney;
  }

  Future<Journey> getLastJourney() async {
    final response = await api.get(LAST_JOURNEY_PATH);
    final journeyRaw = response['body']['journey'];
    final rawResponse = response['response'];

    if (rawResponse.statusCode == HttpStatus.notFound) {
      return null;
    } else if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error getting the last journey');
    }

    final journey = Journey.fromRequestJson(journeyRaw);

    return journey;
  }

  Future<FullJourney> getJourney(String id) async {
    final response = await api.get(getJourneyPath(id));
    final journeyRaw = response['body']['journey'];
    final rawResponse = response['response'];

    if (rawResponse.statusCode == HttpStatus.notFound) {
      return null;
    } else if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error getting the journey');
    }

    final journey = FullJourney.fromJson(journeyRaw);

    return journey;
  }
}
