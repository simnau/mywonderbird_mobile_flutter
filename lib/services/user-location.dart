import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/services/api.dart';

const FIND_ALL_PATH = "/api/gems";
final deleteByIdPath = (String id) => "/api/gems/$id";
final findByIdPath = (String id) => "/api/gems/$id";
final findByUserIdPath = (String id) => "/api/gems/users/$id";

class UserLocationService {
  final API api;

  UserLocationService({
    @required this.api,
  });

  Future<LocationModel> findById(String id) async {
    final response = await api.get(findByIdPath(id));
    final locationRaw = response['body'];

    final location = LocationModel.fromResponseJson(locationRaw['gem']);

    return location;
  }

  Future<List<LocationModel>> findAllUserLocations() async {
    final response = await api.get(FIND_ALL_PATH);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('An error occurred'); // TODO handle properly
    }

    final locationsRaw = response['body']['gems'];

    final locations = locationsRaw.map<LocationModel>((location) {
      return LocationModel.fromResponseJson(location);
    }).toList();

    return locations;
  }

  Future<List<LocationModel>> findAllLocationsByUserId(String userId) async {
    final response = await api.get(findByUserIdPath(userId));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('An error occurred'); // TODO handle properly
    }

    final locationsRaw = response['body']['gems'];

    final locations = locationsRaw.map<LocationModel>((location) {
      return LocationModel.fromResponseJson(location);
    }).toList();

    return locations;
  }

  deleteById(String id) async {
    final response = await api.delete(deleteByIdPath(id));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('An error occurred'); // TODO handle properly
    }
  }
}
