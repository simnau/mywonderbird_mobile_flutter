import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mywonderbird/components/small-icon-button.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/util/geo.dart';

class LocationDetails extends StatelessWidget {
  final SuggestedLocation item;
  final LocationData userLocation;
  final void Function() onTap;

  const LocationDetails({
    Key key,
    @required this.item,
    @required this.onTap,
    @required this.userLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _title(),
                SizedBox(height: 4.0),
                _country(),
                SizedBox(height: 4.0),
                _distanceFromUser(),
              ],
            ),
          ),
          SmallIconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 32.0,
            ),
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return H6.light(
      item.name,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _country() {
    return Row(
      children: [
        Icon(
          SimpleLineIcons.location_pin,
          color: Colors.white,
        ),
        SizedBox(width: 4),
        Subtitle2.light(
          item.country,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _distanceFromUser() {
    final distanceInKilometers = userLocation != null
        ? getDistanceInKilometers(
            LatLng(userLocation.latitude, userLocation.longitude),
            item.latLng,
          ).toStringAsFixed(2)
        : null;

    return Row(
      children: [
        Icon(
          SimpleLineIcons.graph,
          color: Colors.white,
        ),
        SizedBox(width: 4),
        Subtitle2.light(
          "${distanceInKilometers ?? '-'} kilometers away",
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
