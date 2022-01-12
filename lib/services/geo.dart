import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/location.dart';

import 'api.dart';

const DEFAULT_LOCATION_STRING = '0,0';

const SEARCH_FOR_PLACES_PATH = '/api/geo/places/search';
const REVERSE_GEOCODE_PATH = '/api/geo/places/reverse-geocode';

class GeoService {
  final API api;

  GeoService({@required this.api});

  Future<List<LocationModel>> searchLocations(
    String query,
    Position currentLocation,
  ) async {
    final location = currentLocation != null
        ? "${currentLocation.latitude},${currentLocation.longitude}"
        : DEFAULT_LOCATION_STRING;
    final response = await api.get(
      SEARCH_FOR_PLACES_PATH,
      params: {'q': query, 'location': location},
    );
    final placesRaw = response['body'];

    final List<LocationModel> locations = placesRaw
        .map<LocationModel>(
            (location) => LocationModel.fromResponseJson(location))
        .toList();

    return locations;
  }

  Future<LocationModel> reverseGeocode(LatLng coordinates) async {
    final locationString = "${coordinates.latitude},${coordinates.longitude}";
    final params = Map<String, String>.from({'location': locationString});
    final response = await api.get(
      REVERSE_GEOCODE_PATH,
      params: params,
    );
    final location = LocationModel.fromResponseJson(
      response['body']['place'],
    );

    return location;
  }

  Future<List<LocationModel>> multiReverseGeocode(
      List<LatLng> coordinates) async {
    final body = Map<String, dynamic>.from({
      'locations': coordinates
          .map(
            (location) => {
              'latLng': location?.toJson(),
            },
          )
          .toList()
    });
    final response = await api.post(REVERSE_GEOCODE_PATH, body);
    final locationsRaw = response['body']['locations'];
    final locations = locationsRaw
        .map<LocationModel>(
          (location) => location != null
              ? LocationModel.fromResponseJson(location)
              : null,
        )
        .toList();

    return locations;
  }
}
