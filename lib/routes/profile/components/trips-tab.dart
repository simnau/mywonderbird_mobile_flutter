import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/journeys.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:provider/provider.dart';

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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Subtitle1(
                'You have no trips',
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              Padding(padding: const EdgeInsets.only(bottom: 8.0)),
              Subtitle2(
                'Once you create a trip it will appear here',
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
      itemBuilder: (_, index) => _buildJourneyListItem(
        journeysProvider.journeys[index],
      ),
      itemCount: journeysProvider.journeys.length,
    );
  }

  Widget _buildJourneyListItem(Journey journey) {
    return Container(
      child: ListTile(
        onTap: () => _viewJourney(journey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 8.0,
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
        subtitle: Subtitle2(journey.country ?? '-'),
      ),
    );
  }

  _viewJourney(Journey item) async {
    final journeyService = locator<JourneyService>();
    final journey = await journeyService.getJourney(item.id);

    locator<NavigationService>().push(
      MaterialPageRoute(
        builder: (context) => TripOverview(
          journey: journey,
        ),
      ),
    );
  }
}
