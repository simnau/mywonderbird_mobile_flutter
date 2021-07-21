import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/models/suggested-location-image.dart';
import 'package:mywonderbird/models/suggested-location.dart';

class SuggestedLocationConverter {
  SuggestedLocation convertFrom(LocationModel location) {
    return SuggestedLocation(
      id: location.id,
      country: location.country,
      countryCode: location.countryCode,
      name: location.name,
      latLng: location.latLng,
      images: [
        SuggestedLocationImage(
          name: location.name,
          url: location.imageUrl,
        ),
      ],
    );
  }
}
