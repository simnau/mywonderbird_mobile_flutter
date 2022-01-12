import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/routes/profile/components/stat-item.dart';

class Stats extends StatelessWidget {
  final int tripCount;
  final int plannedTripCount;
  final int spotCount;
  final int countryCount;
  final Function() onViewTrips;
  final Function() onViewPlans;
  final Function() onViewSpots;
  final Function() onViewCountries;

  const Stats({
    Key key,
    @required this.tripCount,
    @required this.plannedTripCount,
    @required this.spotCount,
    @required this.countryCount,
    @required this.onViewTrips,
    @required this.onViewPlans,
    @required this.onViewSpots,
    @required this.onViewCountries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _item(tripCount, "Trips", onViewTrips),
        _item(plannedTripCount, "Plans", onViewPlans),
        _item(spotCount, "Spots", onViewSpots),
        _item(countryCount, "Countries", onViewCountries),
      ],
    );
  }

  Widget _item(int count, String title, Function() onTap) {
    return Expanded(
      child: StatItem(
        count: count,
        title: title,
        onTap: onTap,
        padding: EdgeInsets.symmetric(vertical: spacingFactor(3.0)),
      ),
    );
  }
}
