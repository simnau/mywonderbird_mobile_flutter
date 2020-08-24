import 'package:flutter/material.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:provider/provider.dart';

class TripsTab extends StatefulWidget {
  @override
  _TripsTabState createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
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
        title: Text(
          journey.country ?? '-',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          journey.startDate.year.toString(),
          style: TextStyle(
            fontSize: 18,
            color: Colors.black26,
          ),
        ),
      ),
    );
  }

  // TODO implement this
  _viewJourney(Journey journey) {}
}
