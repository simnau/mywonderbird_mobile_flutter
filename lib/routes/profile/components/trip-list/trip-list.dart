import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/routes/profile/components/trip-card.dart';

class TripList extends StatelessWidget {
  final List<TripStats> trips;
  final bool renderProgress;
  final Function(TripStats tripStats) onViewTrip;
  final EdgeInsetsGeometry padding;
  final Widget actionButton;
  final Widget emptyListPlaceholder;

  const TripList({
    Key key,
    @required this.trips,
    @required this.renderProgress,
    @required this.onViewTrip,
    this.padding,
    this.actionButton,
    this.emptyListPlaceholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      if (emptyListPlaceholder != null) {
        return Center(child: emptyListPlaceholder);
      } else {
        return Container();
      }
    }

    return ListView.separated(
      padding: padding,
      separatorBuilder: (_, index) => SizedBox(
        height: index == trips.length ? spacingFactor(1) : spacingFactor(2),
      ),
      itemBuilder: _item,
      itemCount: actionButton != null ? trips.length + 1 : trips.length,
    );
  }

  Widget _item(BuildContext context, int index) {
    if (index == trips.length) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: spacingFactor(6)),
        child: Center(child: actionButton),
      );
    }

    final tripStats = trips[index];

    return TripCard(
      onViewTrip: onViewTrip,
      renderProgress: renderProgress,
      tripStats: tripStats,
      roundedBorders: true,
    );
  }
}
