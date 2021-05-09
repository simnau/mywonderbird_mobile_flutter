import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/suggested-journey.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationsTab extends StatelessWidget {
  final List<SuggestedLocation> locations;
  final Function(SuggestedLocation) onRemoveLocation;
  final Function(SuggestedLocation, String event) onViewLocation;
  final bool isLoading;
  final SuggestedJourney suggestedTrip;

  const LocationsTab({
    Key key,
    @required this.locations,
    @required this.onRemoveLocation,
    @required this.onViewLocation,
    @required this.isLoading,
    @required this.suggestedTrip,
  }) : super(key: key);

  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading && suggestedTrip == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (locations.isEmpty) {
      return EmptyListPlaceholder(
        title: 'Woops!',
        subtitle:
            'Looks like you removed all of the locations. No trip to be had here :(',
        action: ElevatedButton(
          child: BodyText1.light('Back'),
          style: ElevatedButton.styleFrom(primary: theme.primaryColor),
          onPressed: _onBack,
        ),
      );
    }

    return ListView.separated(
      itemBuilder: _location,
      itemCount: locations.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
      ),
    );
  }

  Widget _location(context, locationIndex) {
    final location = locations[locationIndex];
    final imageUrl = location.coverImage?.url;
    final theme = Theme.of(context);
    final onViewDetails = () => onViewLocation(
          location,
          LOCATION_INFO_SUGGESTED_LIST,
        );

    return ListTile(
      onTap: onViewDetails,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 8.0,
      ),
      title: Subtitle1(
        location.name,
        overflow: TextOverflow.ellipsis,
      ),
      leading: AspectRatio(
        aspectRatio: 1,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.grey,
          ),
          child: imageUrl != null
              ? FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: imageUrl,
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete_forever,
          color: isLoading ? theme.disabledColor : Colors.red,
        ),
        onPressed: isLoading ? null : () => onRemoveLocation(location),
      ),
    );
  }

  _onBack() {
    final navigationService = locator<NavigationService>();

    navigationService.pop();
  }
}
