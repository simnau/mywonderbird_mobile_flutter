import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/models/journey.dart';

class TripsList extends StatelessWidget {
  final List<Journey> trips;
  final void Function(Journey trip) onView;

  const TripsList({
    Key key,
    @required this.trips,
    @required this.onView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemBuilder: (_, index) => _buildJourneyListItem(trips[index]),
      itemCount: trips.length,
    );
  }

  Widget _buildJourneyListItem(Journey trip) {
    return Container(
      child: ListTile(
        onTap: () => onView(trip),
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
}
