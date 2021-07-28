import 'package:flutter/material.dart';
import 'package:mywonderbird/models/location.dart';

import 'journey.dart';

const SHOWCASE_PICTURE_COUNT = 3;

class FullJourney extends Journey {
  final List<LocationModel> locations;

  FullJourney({
    @required name,
    id,
    country,
    @required startDate,
    finishDate,
    @required imageUrl,
    @required this.locations,
  }) : super(
          name: name,
          id: id,
          country: country,
          startDate: startDate,
          finishDate: finishDate,
          imageUrl: imageUrl,
        );

  factory FullJourney.fromJson(Map<String, dynamic> json) {
    return FullJourney(
      id: json['id'],
      name: json['title'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      finishDate: json['finishDate'] != null
          ? DateTime.parse(json['finishDate'])
          : null,
      imageUrl: json['imageUrl'],
      country: json['country'],
      locations: json['locations']
              ?.map<LocationModel>(
                  (location) => LocationModel.fromResponseJson(location))
              ?.toList() ??
          [],
    );
  }

  List<LocationModel> get locationsWithImages {
    return this
        .locations
        .where((location) => location.imageUrl != null)
        .toList();
  }

  List<LocationModel> get showCaseLocations {
    if (locationsWithImages.length <= SHOWCASE_PICTURE_COUNT) {
      return this.locations;
    }

    return locationsWithImages.sublist(0, SHOWCASE_PICTURE_COUNT);
  }

  int get morePictureCount =>
      locationsWithImages.length - SHOWCASE_PICTURE_COUNT;
  bool get hasMorePictures =>
      locationsWithImages.length > SHOWCASE_PICTURE_COUNT;

  String get countryDescription {
    if (country == null) {
      return null;
    }

    return "Starts in $country";
  }
}
