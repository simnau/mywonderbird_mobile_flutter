import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookmarkedLocationModel {
  final String id;
  final String gemCaptureId;
  final String title;
  final String country;
  final String imageUrl;
  final LatLng latLng;

  const BookmarkedLocationModel({
    this.id,
    this.gemCaptureId,
    @required this.title,
    @required this.country,
    @required this.imageUrl,
    @required this.latLng,
  });

  factory BookmarkedLocationModel.fromResponseJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    final location = json['location'];
    final lat = location['lat'];
    final lng = location['lng'];

    return BookmarkedLocationModel(
      id: json['id'],
      gemCaptureId: json['gemCaptureId'],
      title: json['title'],
      country: json['country'],
      imageUrl: json['imageUrl'],
      latLng: LatLng(lat, lng),
    );
  }
}
