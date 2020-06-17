import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:layout/routes/share-picture/mock.dart';
import 'package:layout/types/named-item.dart';

class Location extends NamedItem {
  final String id;
  final String country;
  final String imageUrl;
  final LatLng latLng;

  const Location({
    @required name,
    this.id,
    @required this.country,
    @required this.imageUrl,
    @required this.latLng,
  }) : super(name: name);

  factory Location.fromResponseJson(Map<String, dynamic> json) {
    final location = json['location'];
    final lat = location['lat'];
    final lng = location['lng'];

    return Location(
      id: json['id'],
      name: json['name'],
      country: 'TODO',
      imageUrl: MOCK_IMAGE, // TODO
      latLng: LatLng(lat, lng),
    );
  }
}
