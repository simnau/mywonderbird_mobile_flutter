import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/models/saved-trip.dart';
import 'package:mywonderbird/services/api.dart';

const ROOT_PATH = '/api/saved-trips';
const SAVED_TRIPS_PATH = ROOT_PATH;
const SAVE_TRIP_PATH = ROOT_PATH;
final savedTripsByUserIdPath = (userId) => "$ROOT_PATH/users/$userId";
final savedTripByIdPath = (id) => "$ROOT_PATH/$id";
final updateTripByIdPath = (id) => "$ROOT_PATH/$id";
final startTripAtLocationPath = (id) => "$ROOT_PATH/$id/from-point";
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
    final trips =
        tripsRaw.map<Journey>((trip) => Journey.fromRequestJson(trip)).toList();

    return trips;
  }

  Future<List<Journey>> fetchByUserId(userId) async {
    final response = await api.get(savedTripsByUserIdPath(userId));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error fetching trips');
    }

    final tripsRaw = response['body']['trips'];
    final trips =
        tripsRaw.map<Journey>((trip) => Journey.fromRequestJson(trip)).toList();

    return trips;
  }

  Future<FullJourney> fetch(String id) async {
    final response = await api.get(savedTripByIdPath(id));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error fetching the trip');
    }

    final tripRaw = response['body']['trip'];
    final trip = FullJourney.fromJson(tripRaw);

    return trip;
  }

  Future<Journey> saveTrip(SavedTrip trip) async {
    final response = await api.post(SAVE_TRIP_PATH, {
      "trip": trip.toJson(),
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error saving the trip');
    }

    final tripRaw = response['body']['trip'];
    final savedTrip = FullJourney.fromJson(tripRaw);

    return savedTrip;
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

  Future<FullJourney> updateTripLocations(
    String id,
    List<LocationModel> newLocations,
  ) async {
    final response = await api.put(updateTripByIdPath(id), {
      'trip': {
        'savedTripLocations': newLocations
            .map(
              (location) => ({
                'savedTripId': id,
                'placeId': location.placeId,
                'skipped': location.skipped,
                'visitedAt': location.visitedAt,
              }),
            )
            .toList(),
      },
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error updating the trip locations');
    }

    final tripRaw = response['body']['trip'];
    final updatedTrip = FullJourney.fromJson(tripRaw);

    return updatedTrip;
  }

  Future<FullJourney> startTripAtLocation(
    String tripId,
    String startingLocationId,
  ) async {
    final response = await api.put(startTripAtLocationPath(tripId), {
      'startingLocationId': startingLocationId,
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception(
        "There was an error starting the trip from location $startingLocationId",
      );
    }

    final tripRaw = response['body']['trip'];
    final updatedTrip = FullJourney.fromJson(tripRaw);

    return updatedTrip;
  }
}
