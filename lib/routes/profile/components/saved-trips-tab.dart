import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/saved-trips-list.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/providers/saved-trips.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:provider/provider.dart';

class SavedTripsTab extends StatefulWidget {
  @override
  _SavedTripsTabState createState() => _SavedTripsTabState();
}

class _SavedTripsTabState extends State<SavedTripsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchSavedTrips());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildList(),
    );
  }

  Widget _buildList() {
    final savedTripsProvider = Provider.of<SavedTripsProvider>(
      context,
    );

    if (savedTripsProvider.loading) {
      return Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (savedTripsProvider.savedTrips.isEmpty) {
      return EmptyListPlaceholder(
        title: 'You have no saved trips',
        subtitle: 'Once you save a trip it will appear here',
      );
    }

    return SavedTripsList(
      savedTrips: savedTripsProvider.savedTrips,
      onView: _viewSavedTrip,
      onDelete: _onDeleteSavedTrip,
    );
  }

  _viewSavedTrip(Journey trip) async {
    final navigationService = locator<NavigationService>();

    await navigationService.push(
      MaterialPageRoute(
        builder: (context) => SavedTripOverview(
          id: trip.id,
        ),
      ),
    );

    _fetchSavedTrips();
  }

  _fetchSavedTrips() async {
    final savedTripsProvider = locator<SavedTripsProvider>();
    await savedTripsProvider.loadUserSavedTrips();
  }

  _onDeleteSavedTrip(Journey trip, BuildContext context) async {
    try {
      final savedTripsProvider = locator<SavedTripsProvider>();
      await savedTripsProvider.deleteTrip(trip);
    } catch (e) {
      final snackBar = SnackBar(
        content: Text(
          e.message,
          style: TextStyle(color: Colors.red),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
