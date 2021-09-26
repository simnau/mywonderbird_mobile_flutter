import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/routes/details/pages/user-location-details.dart';
import 'package:mywonderbird/routes/profile/components/spots-list.dart';
import 'package:mywonderbird/services/user-location.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/util/snackbar.dart';

class MySpotsTab extends StatefulWidget {
  @override
  _MySpotsTabState createState() => _MySpotsTabState();
}

class _MySpotsTabState extends State<MySpotsTab> {
  bool isLoading = true;
  List<LocationModel> spots;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchUserLocations());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildList(),
    );
  }

  Widget _buildList() {
    if (isLoading) {
      return Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (spots.isEmpty) {
      return EmptyListPlaceholder(
        title: 'You have no spots shared',
        subtitle: 'Once you share a spot, it will appear here',
      );
    }

    return SpotsList(
      spots: spots,
      onView: _viewSpot,
      onDelete: _onDeleteSpot,
    );
  }

  _viewSpot(LocationModel location) async {
    final navigationService = locator<NavigationService>();

    await navigationService.push(
      MaterialPageRoute(
        builder: (context) => UserLocationDetails(
          locationId: location.id,
        ),
      ),
    );
  }

  _fetchUserLocations() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userLocationsService = locator<UserLocationService>();
      final locations = await userLocationsService.findAllUserLocations();

      setState(() {
        this.spots = locations;
        isLoading = false;
      });
    } catch (e) {
      final snackBar = createErrorSnackbar(text: e.message);

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _onDeleteSpot(LocationModel location, BuildContext context) async {
    try {
      final userLocationsService = locator<UserLocationService>();
      await userLocationsService.deleteById(location.id);

      setState(() {
        spots.remove(location);
      });
    } catch (e) {
      final snackBar = createErrorSnackbar(text: e.message);

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
