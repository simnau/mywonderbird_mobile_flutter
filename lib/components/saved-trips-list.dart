import 'package:flutter/material.dart';
import 'package:mywonderbird/models/journey.dart';

import 'trip-progress-indicator.dart';
import 'typography/subtitle1.dart';
import 'typography/subtitle2.dart';

class SavedTripsList extends StatelessWidget {
  final List<Journey> savedTrips;
  final void Function(Journey trip) onView;
  final void Function(Journey trip, BuildContext buildContext) onDelete;

  const SavedTripsList({
    Key key,
    @required this.savedTrips,
    @required this.onView,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemBuilder: (context, index) => _buildTripListItem(index, context),
      itemCount: savedTrips.length,
    );
  }

  Widget _buildTripListItem(int index, BuildContext context) {
    final trip = savedTrips[index];

    return Container(
      child: ListTile(
        onTap: () => trip.finishDate != null ? null : onView(trip),
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
            TripProgressIndicator(trip: trip),
          ],
        ),
        trailing: onDelete == null
            ? null
            : IconButton(
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),
                onPressed: () => onDelete(trip, context),
              ),
        isThreeLine: true,
      ),
    );
  }
}
