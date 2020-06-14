import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
}
