import 'package:mywonderbird/models/full-journey.dart';

import 'suggested-location.dart';

class SuggestedJourney extends FullJourney {
  final String countryCode;

  SuggestedJourney({
    imageUrl,
    country,
    locations,
    this.countryCode,
  }) : super(
          imageUrl: imageUrl,
          locations: locations,
          country: country,
        );

  factory SuggestedJourney.fromJson(Map<String, dynamic> json) {
    return SuggestedJourney(
      imageUrl: json['imageUrl'],
      country: json['country'],
      countryCode: json['countryCode'],
      locations: json['locations']
          ?.map<SuggestedLocation>(
            (locationJson) => SuggestedLocation.fromJson(locationJson),
          )
          ?.toList(),
    );
  }
}
