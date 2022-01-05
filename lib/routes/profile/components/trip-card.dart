import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/routes/profile/components/trip-progress.dart';

const double CARD_HEIGHT = 215;

class TripCard extends StatelessWidget {
  final TripStats tripStats;
  final bool renderProgress;
  final bool roundedBorders;
  final Function(TripStats tripStats) onViewTrip;
  final Function(TripStats tripStats) onDeleteTrip;
  final bool showActions;

  const TripCard({
    Key key,
    @required this.tripStats,
    @required this.renderProgress,
    @required this.onViewTrip,
    @required this.showActions,
    this.onDeleteTrip,
    bool roundedBorders,
  })  : this.roundedBorders = roundedBorders ?? true,
        super(key: key);

  int get _currentStep => tripStats.currentStep;
  int get _totalSteps => tripStats.spotCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CARD_HEIGHT,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: roundedBorders
            ? BorderRadius.all(Radius.circular(borderRadiusFactor(4)))
            : null,
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
          if (showActions)
            Positioned(
              top: 0,
              right: 0,
              child: _actions(),
            ),
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

  Widget _actions() {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton(
        icon: Icon(
          Icons.more_horiz,
          color: Colors.white,
        ),
        iconSize: 24,
        tooltip: "Action menu",
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadiusFactor(2),
          ),
        ),
        itemBuilder: (_) {
          return <PopupMenuEntry>[
            PopupMenuItem(
              child: Subtitle2(
                "Delete",
                color: Colors.black87,
              ),
              onTap: _delete,
            ),
          ];
        },
      ),
    );
  }

  _viewTrip() {
    onViewTrip(tripStats);
  }

  _delete() {
    // This makes sure that the item is closed when onDelete is invoked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onDeleteTrip(tripStats);
    });
  }
}
