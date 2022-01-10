import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/saved-trip.dart';

class SavedTripOverviewGeneric extends StatelessWidget {
  final String id;

  const SavedTripOverviewGeneric({
    Key key,
    @required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TripOverviewScreen(
      loadTrip: _loadTrip,
    );
  }

  Future<FullJourney> _loadTrip() {
    final savedTripService = locator<SavedTripService>();

    return savedTripService.fetch(id);
  }
}
