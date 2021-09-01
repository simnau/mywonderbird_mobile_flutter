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
  final List<T> locations;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition) onCameraMove;
  final Function() onGoToMyLocation;
  final Function(T) onViewLocation;
  final Function() onSaveTrip;
  final Function() onStart;
  final Function() onEdit;
  final Function() onSaveEdit;
  final Function() onCancelEdit;
  final Function(T, BuildContext) onSkip;
  final Function(T, BuildContext) onVisit;
  final Function(T) onNavigate;
  final Function(T) onRemove;
  final Function(T) onStartFromLocation;
  final ItemScrollController itemScrollController;
  final bool isSaved;
  final bool isEditing;
  final bool isRecalculatingRoute;

  const VerticalSplitView({
    Key key,
    @required this.currentLocationIndex,
    @required this.trip,
    @required this.locations,
    @required this.onMapCreated,
    @required this.onCameraMove,
    @required this.onViewLocation,
    @required this.onGoToMyLocation,
    this.onSaveTrip,
    this.onStart,
    this.onSkip,
    this.onVisit,
    this.onNavigate,
    this.itemScrollController,
    this.isSaved,
    this.isRecalculatingRoute,
    @required this.onEdit,
    @required this.onSaveEdit,
    @required this.onCancelEdit,
    @required this.onRemove,
    bool isEditing,
    @required this.onStartFromLocation,
  })  : isEditing = isEditing ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SplitView(
      children: [
        TripMap<T>(
          locations: locations,
          currentLocationIndex: currentLocationIndex,
          onMapCreated: onMapCreated,
          onCameraMove: onCameraMove,
          onGoToMyLocation: onGoToMyLocation,
          isTripStarted: trip?.startDate != null,
        ),
        TripDetails<T>(
          trip: trip,
          locations: locations,
          currentLocationIndex: currentLocationIndex,
          onViewLocation: onViewLocation,
          onSaveTrip: onSaveTrip,
          onStart: onStart,
          onSkip: onSkip,
          onVisit: onVisit,
          onNavigate: onNavigate,
          itemScrollController: itemScrollController,
          isSaved: isSaved,
          isEditing: isEditing,
          isRecalculatingRoute: isRecalculatingRoute,
          onEdit: onEdit,
          onSaveEdit: onSaveEdit,
          onCancelEdit: onCancelEdit,
          onRemove: onRemove,
          onStartFromLocation: onStartFromLocation,
        ),
      ],
      viewMode: SplitViewMode.Vertical,
      controller: SplitViewController(
        limits: [
          WeightLimit(min: 0.35),
          WeightLimit(min: 0.25),
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
