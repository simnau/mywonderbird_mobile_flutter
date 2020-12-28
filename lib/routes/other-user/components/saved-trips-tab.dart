import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/saved-trips-list.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/saved-trip.dart';

class SavedTripsTab extends StatefulWidget {
  final String userId;

  const SavedTripsTab({
    Key key,
    this.userId,
  }) : super(key: key);

  @override
  _SavedTripsTabState createState() => _SavedTripsTabState();
}

class _SavedTripsTabState extends State<SavedTripsTab> {
  bool _isLoading = true;
  List<Journey> _savedTrips = [];

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
    if (_isLoading) {
      return Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_savedTrips.isEmpty) {
      return EmptyListPlaceholder(
        title: 'This user has no saved trips',
      );
    }

    return SavedTripsList(
      savedTrips: _savedTrips,
      onView: _viewSavedTrip,
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
  }

  _fetchSavedTrips() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final savedTripService = locator<SavedTripService>();
      final savedTrips = await savedTripService.fetchByUserId(widget.userId);

      setState(() {
        _isLoading = false;
        _savedTrips = savedTrips;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
