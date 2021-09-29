import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:provider/provider.dart';

import '../../components/trips-list.dart';

class MyTripsTab extends StatefulWidget {
  @override
  _MyTripsTabState createState() => _MyTripsTabState();
}

class _MyTripsTabState extends State<MyTripsTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildList(),
    );
  }

  Widget _buildList() {
    final journeysProvider = Provider.of<JourneysProvider>(
      context,
    );

    if (journeysProvider.loading) {
      return Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (journeysProvider.journeys.isEmpty) {
      return EmptyListPlaceholder(
        title: 'You have no trips',
        subtitle: 'Once you create a trip it will appear here',
      );
    }

    return TripsList(
      trips: journeysProvider.journeys,
      onView: _viewTrip,
    );
  }

  _viewTrip(Journey trip) async {
    locator<NavigationService>().push(
      MaterialPageRoute(
        builder: (context) => TripOverview(
          id: trip.id,
        ),
      ),
    );
  }
}
