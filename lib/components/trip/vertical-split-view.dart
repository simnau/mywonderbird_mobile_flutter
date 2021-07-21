import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:split_view/split_view.dart';

import 'trip-details.dart';
import 'trip-map.dart';

class VerticalSplitView extends StatelessWidget {
  final List<LocationModel> locations;
  final int currentLocationIndex;
  final FullJourney trip;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition) onCameraMove;
  final Function(LocationModel) onViewLocation;
  final Function() onStart;
  final Function(LocationModel, BuildContext) onSkip;
  final Function(LocationModel, BuildContext) onVisit;

  const VerticalSplitView({
    Key key,
    @required this.locations,
    @required this.currentLocationIndex,
    @required this.trip,
    @required this.onMapCreated,
    @required this.onCameraMove,
    @required this.onViewLocation,
    this.onStart,
    this.onSkip,
    this.onVisit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SplitView(
      children: [
        TripMap(
          locations: locations,
          currentLocationIndex: currentLocationIndex,
          onMapCreated: onMapCreated,
          onCameraMove: onCameraMove,
        ),
        TripDetails(
          trip: trip,
          locations: locations,
          currentLocationIndex: currentLocationIndex,
          onViewLocation: onViewLocation,
          onStart: onStart,
          onSkip: onSkip,
          onVisit: onVisit,
        ),
      ],
      viewMode: SplitViewMode.Vertical,
      controller: SplitViewController(
        limits: [
          WeightLimit(min: 0.35),
          WeightLimit(min: 0.1),
        ],
        weights: [
          0.35,
          0.65,
        ],
      ),
      indicator: Container(
        height: 8,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey,
        ),
      ),
      gripColor: Colors.white,
      gripColorActive: Colors.white,
      gripSize: 16,
    );
  }
}
