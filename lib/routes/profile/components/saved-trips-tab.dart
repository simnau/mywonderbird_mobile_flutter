import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/saved-trip.dart';

class SavedTripsTab extends StatefulWidget {
  @override
  _SavedTripsTabState createState() => _SavedTripsTabState();
}

class _SavedTripsTabState extends State<SavedTripsTab> {
  bool _isLoading = false;
  List<Journey> journeys = [];

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

    if (journeys.isEmpty) {
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
      itemBuilder: (context, index) => _buildJourneyListItem(index, context),
      itemCount: journeys.length,
    );
  }

  Widget _buildJourneyListItem(int index, BuildContext context) {
    final journey = journeys[index];

    return Container(
      child: ListTile(
        onTap: () =>
            journey.finishDate != null ? null : _viewSavedJourney(journey),
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
          child: journey.imageUrl != null
              ? Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    journey.imageUrl,
                  ),
                )
              : Container(
                  color: Colors.black26,
                ),
        ),
        title: Subtitle1(journey.name ?? '-'),
        subtitle: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 4.0,
          children: [
            Subtitle2(journey.country),
            _progressIndicator(journey),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_forever,
            color: Colors.red,
          ),
          onPressed: () => _onDeleteSavedTrip(journey, context),
        ),
        isThreeLine: true,
      ),
    );
  }

  _viewSavedJourney(Journey journey) {
    final navigationService = locator<NavigationService>();

    navigationService.push(
      MaterialPageRoute(
        builder: (context) => SavedTripOverview(
          id: journey.id,
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

      final savedJourneys = await savedTripService.fetchAll();
      setState(() {
        _isLoading = false;
        journeys = savedJourneys;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _onDeleteSavedTrip(Journey journey, BuildContext context) async {
    try {
      final savedTripService = locator<SavedTripService>();

      await savedTripService.deleteTrip(journey.id);
      setState(() {
        journeys.remove(journey);
      });
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

  Widget _progressIndicator(Journey journey) {
    if (journey.finishDate != null) {
      return Subtitle2(
        'Finished',
        color: Colors.green[900],
      );
    }

    if (journey.startDate != null) {
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
