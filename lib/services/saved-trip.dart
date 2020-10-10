import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/models/saved-trip.dart';
import 'package:mywonderbird/services/api.dart';

const ROOT_PATH = '/api/saved-trips';
const SAVED_TRIPS_PATH = ROOT_PATH;
const SAVE_TRIP_PATH = ROOT_PATH;
final savedTripByIdPath = (id) => "$ROOT_PATH/$id";
final deleteSavedTripPath = (id) => "$ROOT_PATH/$id";
final startTripPath = (id) => "$ROOT_PATH/$id/started";
final skipLocationPath =
    (tripId, locationId) => "$ROOT_PATH/$tripId/locations/$locationId/skipped";
final visitLocationPath =
    (tripId, locationId) => "$ROOT_PATH/$tripId/locations/$locationId/visited";
final endTripPath = (tripId) => "$ROOT_PATH/$tripId/ended";

class SavedTripService {
  final API api;

  SavedTripService({
    @required this.api,
  });

  Future<List<Journey>> fetchAll() async {
    final response = await api.get(SAVED_TRIPS_PATH);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error fetching trips');
    }

    final tripsRaw = response['body']['trips'];
    final journeys =
        tripsRaw.map<Journey>((trip) => Journey.fromRequestJson(trip)).toList();

    return journeys;
  }

  Future<FullJourney> fetch(String id) async {
    final response = await api.get(savedTripByIdPath(id));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error fetching the trip');
    }

    final tripRaw = response['body']['trip'];
    final journey = FullJourney.fromJson(tripRaw);

    return journey;
  }

  Future<Journey> saveTrip(SavedTrip trip) async {
    final response = await api.post(SAVE_TRIP_PATH, trip.toJson());
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error saving the trip');
    }

    final tripRaw = response['body']['trip'];
    final journey = FullJourney.fromJson(tripRaw);

    return journey;
  }

  deleteTrip(String id) async {
    final response = await api.delete(deleteSavedTripPath(id));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error deleting the trip');
    }
  }

  startTrip(String id) async {
    final response = await api.post(startTripPath(id), {});
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error starting the trip');
    }
  }

  skipLocation(String id, String locationId) async {
    final response = await api.post(
      skipLocationPath(id, locationId),
      {},
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error skipping the location');
    }
  }

  visitLocation(String id, String locationId) async {
    final response = await api.post(
      visitLocationPath(id, locationId),
      {},
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error visiting the location');
    }
  }

  endTrip(String id) async {
    final response = await api.post(
      endTripPath(id),
      {},
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error ending the trip');
    }
  }
}
