import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:location/location.dart';

import 'api.dart';

const DEFAULT_LOCATION_STRING = '0,0';

const SEARCH_FOR_PLACES_PATH = '/api/geo/places/search';
const REVERSE_GEOCODE_PATH = '/api/geo/places/reverse-geocode';

class LocationService {
  final API api;

  LocationService({@required this.api});

  Future<List<LocationModel>> searchLocations(
    String query,
    LocationData currentLocation,
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
}
