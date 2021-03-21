import 'package:mywonderbird/models/suggested-location.dart';

class AreaSelectionSuggestedLocation extends SuggestedLocation {
  final bool isSelected;

  AreaSelectionSuggestedLocation(
      {SuggestedLocation suggestedLocation, this.isSelected})
      : super(
          id: suggestedLocation.id,
          name: suggestedLocation.name,
          latLng: suggestedLocation.latLng,
          country: suggestedLocation.country,
          countryCode: suggestedLocation.countryCode,
          images: suggestedLocation.images,
        );
}
