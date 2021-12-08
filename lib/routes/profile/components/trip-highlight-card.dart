import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/trip-stats.dart';

import 'trip-progress.dart';

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

  int get _currentStep => tripStats.currentStep;
  int get _totalSteps => tripStats.spotCount;

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
        Container(
          height: CARD_HEIGHT,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(borderRadiusFactor(4))),
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                offset: Offset(0, 4),
                color: Colors.black26,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _card(),
              if (renderProgress && _currentStep != 0)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: TripProgress(
                    currentStep: _currentStep,
                    totalSteps: _totalSteps,
                  ),
                ),
            ],
          ),
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

  Widget _card() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(tripStats.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      height: CARD_HEIGHT,
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
