import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/journeys.dart';

class SharedTripOverviewGeneric extends StatelessWidget {
  final String id;

  const SharedTripOverviewGeneric({
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
    final journeyService = locator<JourneyService>();

    return journeyService.getJourney(id);
  }
}
