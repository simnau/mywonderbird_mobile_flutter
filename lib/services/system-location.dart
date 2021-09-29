import 'package:flutter/material.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/services/api.dart';

final findByIdPath = (String id) => "/api/places/details/$id";

class SystemLocationService {
  final API api;

  SystemLocationService({
    @required this.api,
  });

  Future<LocationModel> findById(String id) async {
    final response = await api.get(findByIdPath(id));
    final locationRaw = response['body'];

    final location = LocationModel.fromResponseJson(locationRaw['place']);

    return location;
  }
}
