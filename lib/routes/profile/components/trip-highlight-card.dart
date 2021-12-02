import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/trip-stats.dart';

class TripHighlightCard extends StatelessWidget {
  final String title;
  final TripStats tripStats;
  final Function(TripStats tripStats) onViewTrip;
  final Function() onViewAll;

  const TripHighlightCard({
    Key key,
    @required this.title,
    @required this.tripStats,
    @required this.onViewTrip,
    @required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Subtitle2(
          title,
          color: Color(0xFF484242),
        ),
        SizedBox(height: spacingFactor(1)),
        _card(),
        SizedBox(height: spacingFactor(1)),
        TextButton(
          onPressed: onViewAll,
          child: H6(
            "View all >",
            color: Color(0xFF484242),
          ),
          style: TextButton.styleFrom(alignment: Alignment.centerLeft),
        ),
      ],
    );
  }

  Widget _card() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(tripStats.imageUrl),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(borderRadiusFactor(4))),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 4),
            color: Colors.black26,
          ),
        ],
      ),
      height: 215,
      child: Container(
        color: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListTile(
                title: H6.light(tripStats.name),
                subtitle: Row(
                  children: [
                    Icon(
                      MaterialCommunityIcons.map_marker,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: spacingFactor(1)),
                    Subtitle1.light(tripStats.country),
                  ],
                ),
              ),
            ),
            Align(
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  onTap: _viewTrip,
                  title: Subtitle1.light("${tripStats.spotCount} spots"),
                  subtitle: Subtitle1.light(
                    tripStats.distance.toDistanceString(),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              alignment: Alignment.bottomLeft,
            ),
          ],
        ),
      ),
    );
  }

  _viewTrip() {
    onViewTrip(tripStats);
  }
}
