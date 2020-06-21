import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:layout/models/location.dart';
import 'package:location/location.dart';

const DEFAULT_LOCATION_STRING = '0,0';

final apiBase = DotEnv().env['API_BASE'];
final searchForPlacesUrl = "$apiBase/api/geo/places/search";
final reverseGeocodeUrl = "$apiBase/api/geo/places/reverse-geocode";

class LocationService {
  static Future<List<LocationModel>> searchLocations(
    String query,
    LocationData currentLocation,
  ) async {
    final location = currentLocation != null
        ? "${currentLocation.latitude},${currentLocation.longitude}"
        : DEFAULT_LOCATION_STRING;
    final queryString = "q=$query&location=$location";
    final response = await http.get("$searchForPlacesUrl?$queryString");
    final placesRaw = json.decode(response.body);

    final List<LocationModel> locations = placesRaw
        .map<LocationModel>(
            (location) => LocationModel.fromResponseJson(location))
        .toList();

    return locations;
  }

  static Future<LocationModel> reverseGeocode(LatLng coordinates) async {
    final locationString = "${coordinates.latitude},${coordinates.longitude}";
    final queryString = "location=$locationString";
    final response = await http.get("$reverseGeocodeUrl?$queryString");
    final placeRaw = json.decode(response.body)['place'];

    final LocationModel location = LocationModel.fromResponseJson(placeRaw);

    return location;
  }
}
