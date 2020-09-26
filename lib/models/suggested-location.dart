import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/types/named-item.dart';

import 'suggested-location-image.dart';

class SuggestedLocation extends NamedItem {
  final String id;
  final String country;
  final String countryCode;
  final LatLng latLng;
  final List<SuggestedLocationImage> images;

  const SuggestedLocation({
    @required name,
    this.id,
    @required this.country,
    @required this.countryCode,
    @required this.latLng,
    @required this.images,
  }) : super(name: name);

  SuggestedLocationImage get coverImage =>
      images != null && images.isNotEmpty ? images.first : null;

  factory SuggestedLocation.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    final lat = json['lat'];
    final lng = json['lng'];

    return SuggestedLocation(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      countryCode: json['countryCode'],
      latLng: LatLng(lat, lng),
      images: json['images']
          ?.map<SuggestedLocationImage>(
              (imageJson) => SuggestedLocationImage.fromJson(imageJson))
          ?.toList(),
    );
  }
}
