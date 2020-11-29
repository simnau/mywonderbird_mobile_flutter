import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Subtitle1('You have no saved trips'),
              Padding(padding: const EdgeInsets.only(bottom: 8.0)),
              Subtitle2(
                'Once you save a trip it will appear here',
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemBuilder: (context, index) => _buildTripListItem(index, context),
      itemCount: savedTripsProvider.savedTrips.length,
    );
  }

  Widget _buildTripListItem(int index, BuildContext context) {
    final savedTripsProvider = Provider.of<SavedTripsProvider>(
      context,
    );

    final trip = savedTripsProvider.savedTrips[index];

    return Container(
      child: ListTile(
        onTap: () => trip.finishDate != null ? null : _viewSavedTrip(trip),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 32.0,
        ),
        leading: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: trip.imageUrl != null
              ? Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    trip.imageUrl,
                  ),
                )
              : Container(
                  color: Colors.black26,
                ),
        ),
        title: Subtitle1(trip.name ?? '-'),
        subtitle: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 4.0,
          children: [
            Subtitle2(trip.country),
            _progressIndicator(trip),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_forever,
            color: Colors.red,
          ),
          onPressed: () => _onDeleteSavedTrip(trip, context),
        ),
        isThreeLine: true,
      ),
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

      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  Widget _progressIndicator(Journey trip) {
    if (trip.finishDate != null) {
      return Subtitle2(
        'Finished',
        color: Colors.green[900],
      );
    }

    if (trip.startDate != null) {
      return Subtitle2(
        'In progress',
        color: Colors.orange[900],
      );
    }

    return Subtitle2(
      'Ready to start',
      color: Colors.blue[900],
    );
  }
}
