import 'package:flutter/material.dart';
import 'package:mywonderbird/models/location.dart';

import 'journey.dart';

const SHOWCASE_PICTURE_COUNT = 3;

class FullJourney extends Journey {
  final List<LocationModel> locations;

  const FullJourney({
    @required name,
    id,
    country,
    @required startDate,
    @required imageUrl,
    @required this.locations,
  }) : super(
          name: name,
          id: id,
          country: country,
          startDate: startDate,
          imageUrl: imageUrl,
        );

  factory FullJourney.fromJson(Map<String, dynamic> json) {
    return FullJourney(
      id: json['id'],
      name: json['name'],
      startDate: json['startDate'],
      imageUrl: json['imageUrl'],
      country: json['country'],
      locations: json['locations']
              ?.map<LocationModel>(
                  (location) => LocationModel.fromResponseJson(location))
              ?.toList() ??
          [],
    );
  }

  List<LocationModel> get showCaseLocations {
    if (this.locations.length <= SHOWCASE_PICTURE_COUNT) {
      return this.locations;
    }

    return this.locations.sublist(0, SHOWCASE_PICTURE_COUNT);
  }

  int get morePictureCount => this.locations.length - SHOWCASE_PICTURE_COUNT;
  bool get hasMorePictures => this.locations.length > SHOWCASE_PICTURE_COUNT;
}
