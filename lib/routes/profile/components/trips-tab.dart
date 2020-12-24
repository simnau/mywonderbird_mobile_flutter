import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
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
      return EmptyListPlaceholder(
        title: 'You have no trips',
        subtitle: 'Once you create a trip it will appear here',
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

  Widget _buildJourneyListItem(Journey trip) {
    return Container(
      child: ListTile(
        onTap: () => _viewJourney(trip),
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
          child: _tripImage(trip),
        ),
        title: Subtitle1(trip.name ?? '-'),
        subtitle: Subtitle2(trip.country ?? '-'),
      ),
    );
  }

  Widget _tripImage(Journey trip) {
    if (trip.imageUrl == null) {
      return Icon(
        FontAwesome.image,
        size: 52.0,
        color: Colors.black12,
      );
    }

    return Image(
      fit: BoxFit.cover,
      image: NetworkImage(
        trip.imageUrl,
      ),
    );
  }

  _viewJourney(Journey item) async {
    locator<NavigationService>().push(
      MaterialPageRoute(
        builder: (context) => TripOverview(
          id: item.id,
        ),
      ),
    );
  }
}
