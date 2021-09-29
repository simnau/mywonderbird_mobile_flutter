import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/types/named-item.dart';
import 'package:mywonderbird/util/date.dart';
import 'package:mywonderbird/util/json.dart';

class LocationModel extends NamedItem {
  final String id;
  final String placeId;
  final String country;
  final String countryCode;
  final String imageUrl;
  final List<String> locationImages;
  final LatLng latLng;
  final String provider;
  final int dayIndex;
  bool skipped;
  DateTime visitedAt;

  LocationModel({
    name,
    this.id,
    this.placeId,
    @required this.country,
    @required this.countryCode,
    this.imageUrl,
    this.locationImages,
    @required this.latLng,
    this.provider,
    this.skipped,
    this.visitedAt,
    this.dayIndex,
  }) : super(name: name);

  factory LocationModel.fromResponseJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    final location = json['location'];
    final lat = location['lat'];
    final lng = location['lng'];

    return LocationModel(
      id: json['id'],
      placeId: json['placeId'],
      name: json['name'],
      country: json['country'],
      countryCode: json['countryCode'],
      imageUrl: json['imageUrl'],
      locationImages:
          json['images']?.map<String>((image) => image.toString())?.toList(),
      latLng: LatLng(lat, lng),
      provider: json['provider'],
      skipped: json['skipped'],
      dayIndex: json['dayIndex'],
      visitedAt:
          json['visitedAt'] != null ? DateTime.parse(json['visitedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return removeNulls({
      'id': id,
      'placeId': placeId,
      'title': name,
      'imageUrl': imageUrl,
      'country': country,
      'countryCode': countryCode,
      'lat': latLng.latitude,
      'lng': latLng.longitude,
      'provider': provider,
      'skipped': skipped,
      'visitedAt': visitedAt,
    });
  }

  Map<String, String> toStringJson() {
    return removeNulls({
      'locationId': id,
      'locationPlaceId': placeId,
      'locationTitle': name,
      'locationImage': imageUrl,
      'locationCountry': country,
      'locationCountryCode': countryCode,
      'locationLat': latLng?.latitude?.toString(),
      'locationLng': latLng?.longitude?.toString(),
      'locationProvider': provider,
      'locationSkipped': skipped?.toString(),
      'locationVisitedAt': formatDateTime(visitedAt),
    });
  }
}
