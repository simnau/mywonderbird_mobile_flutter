import 'suggested-location.dart';

class SuggestedJourney {
  final String imageUrl;
  final String countryCode;
  final String country;
  final List<SuggestedLocation> locations;

  SuggestedJourney({
    this.imageUrl,
    this.countryCode,
    this.country,
    this.locations,
  });

  factory SuggestedJourney.fromJson(Map<String, dynamic> json) {
    return SuggestedJourney(
      imageUrl: json['imageUrl'],
      country: json['country'],
      countryCode: json['countryCode'],
      locations: json['locations']
          ?.map<SuggestedLocation>(
              (locationJson) => SuggestedLocation.fromJson(locationJson))
          ?.toList(),
    );
  }
}
