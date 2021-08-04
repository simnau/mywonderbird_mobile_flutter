import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/location.dart';

import 'suggested-location-image.dart';

class SuggestedLocation extends LocationModel {
  final List<SuggestedLocationImage> images;

  SuggestedLocation({
    @required String name,
    @required String country,
    String id,
    @required String countryCode,
    @required LatLng latLng,
    @required List<SuggestedLocationImage> images,
  })  : images = images,
        super(
          name: name,
          country: country,
          countryCode: countryCode,
          imageUrl:
              images != null && images.isNotEmpty ? images.first?.url : null,
          latLng: latLng,
          id: id,
        );

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
