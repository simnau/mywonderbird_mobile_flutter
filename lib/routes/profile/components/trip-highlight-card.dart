import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/trip-stats.dart';

import 'trip-card.dart';

const double CARD_HEIGHT = 215;

class TripHighlightCard extends StatelessWidget {
  final String title;
  final TripStats tripStats;
  final Function(TripStats tripStats) onViewTrip;
  final Function() onViewAll;
  final bool renderProgress;

  const TripHighlightCard({
    Key key,
    @required this.title,
    @required this.tripStats,
    @required this.onViewTrip,
    @required this.onViewAll,
    @required this.renderProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Subtitle2(
          title,
          color: Color(0xFF484242),
        ),
        SizedBox(height: spacingFactor(1)),
        TripCard(
          onViewTrip: onViewTrip,
          renderProgress: renderProgress,
          tripStats: tripStats,
        ),
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
}
