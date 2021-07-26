import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:split_view/split_view.dart';

import 'trip-details.dart';
import 'trip-map.dart';

class VerticalSplitView<T extends LocationModel> extends StatelessWidget {
  final int currentLocationIndex;
  final FullJourney trip;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition) onCameraMove;
  final Function(T) onViewLocation;
  final Function() onSaveTrip;
  final Function() onStart;
  final Function(T, BuildContext) onSkip;
  final Function(T, BuildContext) onVisit;
  final Function(T) onNavigate;
  final ItemScrollController itemScrollController;
  final bool isSaved;

  const VerticalSplitView({
    Key key,
    @required this.currentLocationIndex,
    @required this.trip,
    @required this.onMapCreated,
    @required this.onCameraMove,
    @required this.onViewLocation,
    this.onSaveTrip,
    this.onStart,
    this.onSkip,
    this.onVisit,
    this.onNavigate,
    this.itemScrollController,
    this.isSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SplitView(
      children: [
        TripMap<T>(
          locations: trip?.locations,
          currentLocationIndex: currentLocationIndex,
          onMapCreated: onMapCreated,
          onCameraMove: onCameraMove,
          isTripStarted: trip?.startDate != null,
        ),
        TripDetails<T>(
          trip: trip,
          currentLocationIndex: currentLocationIndex,
          onViewLocation: onViewLocation,
          onSaveTrip: onSaveTrip,
          onStart: onStart,
          onSkip: onSkip,
          onVisit: onVisit,
          onNavigate: onNavigate,
          itemScrollController: itemScrollController,
          isSaved: isSaved,
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
