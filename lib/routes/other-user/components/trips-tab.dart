import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/trips-list.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/journeys.dart';
import 'package:mywonderbird/services/navigation.dart';

class TripsTab extends StatefulWidget {
  final String userId;

  const TripsTab({
    Key key,
    this.userId,
  }) : super(key: key);

  @override
  _TripsTabState createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  bool _isLoading = true;
  List<Journey> _trips = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTrips());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _body(),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_trips.isEmpty) {
      return EmptyListPlaceholder(
        title: 'The user has no trips',
      );
    }

    return TripsList(
      trips: _trips,
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

  _fetchTrips() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final journeyService = locator<JourneyService>();
      final trips = await journeyService.fetchByUserId(widget.userId);

      setState(() {
        _isLoading = false;
        _trips = trips;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
