import 'package:flutter/material.dart';
import 'package:mywonderbird/components/square-icon-button.dart';
import 'package:mywonderbird/components/trip/location-image.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/location.dart';

import 'location-state.dart';

class LocationItem<T extends LocationModel> extends StatelessWidget {
  final T location;
  final bool isFirst;
  final bool isLast;
  final int number;
  final int locationCount;
  final Function(T) onViewLocation;
  final bool isActive;
  final bool isEditing;
  final bool isTripStarted;
  final bool isRecalculatingRoute;
  final LocationState previousLocationState;
  final Function(T, BuildContext) onSkip;
  final Function(T, BuildContext) onVisit;
  final Function(T) onNavigate;
  final Function(T) onRemove;
  final Function(T) onStartFromLocation;

  const LocationItem({
    Key key,
    @required this.location,
    @required this.isFirst,
    @required this.isLast,
    @required this.number,
    @required this.locationCount,
    @required this.onViewLocation,
    this.isActive,
    bool isEditing,
    this.isTripStarted,
    this.isRecalculatingRoute,
    @required this.onSkip,
    @required this.onVisit,
    @required this.onNavigate,
    @required this.onRemove,
    this.previousLocationState,
    @required this.onStartFromLocation,
  })  : isEditing = isEditing ?? false,
        super(key: key);

  bool get isVisited => location?.visitedAt != null;
  bool get isSkipped => location?.skipped != null && location.skipped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderRadius = BorderRadius.vertical(
      top: Radius.circular(isFirst ? borderRadiusFactor(4) : 0),
      bottom: Radius.circular(!isActive && isLast ? borderRadiusFactor(4) : 0),
    );
    final padding = EdgeInsets.fromLTRB(
      spacingFactor(1),
      isFirst ? spacingFactor(1) : 0,
      spacingFactor(2),
      isLast ? spacingFactor(1) : 0,
    );
    final state = locationStateFromLocation(location, isActive);
    final containerColor = isActive
        ? theme.primaryColorLight
        : theme.primaryColorLight.withOpacity(0.4);

    var trailingWidget;

    if (isEditing && !isVisited && !isSkipped) {
      if (locationCount > 1) {
        trailingWidget = IconButton(
          onPressed: _onRemove,
          icon: Icon(Icons.delete),
          color: theme.accentColor,
        );
      }
    } else if (isActive) {
      trailingWidget = SquareIconButton(
        size: 32,
        icon: Icon(
          Icons.directions,
          color: theme.primaryColorDark,
        ),
        onPressed: _onNavigate,
        backgroundColor: Colors.transparent,
        side: BorderSide(color: theme.primaryColorDark),
        splashColor: theme.primaryColor,
      );
    } else if (!isFirst && !isVisited && !isSkipped) {
      trailingWidget = OutlinedButton(
        onPressed: isRecalculatingRoute ? null : _onStartFromLocation,
        child: BodyText1(isTripStarted ? 'Next here' : 'Start here'),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadiusFactor(2)),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: borderRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onViewLocation,
              child: Column(
                children: [
                  if (!isFirst) _separator(previousLocationState, theme),
                  Container(
                    padding: padding,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      leading: LocationImage(
                        image: NetworkImage(
                          location?.imageUrl,
                        ),
                        number: number,
                        state: state,
                      ),
                      title: Subtitle1(
                        location.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: trailingWidget,
                    ),
                  ),
                  if (!isLast) _separator(state, theme),
                ],
              ),
            ),
          ),
        ),
        if (state == LocationState.active) _activeWidget(state, context),
      ],
    );
  }

  Widget _activeWidget(LocationState state, BuildContext context) {
    final theme = Theme.of(context);
    final verticalLineColor = colorFromLocationState(state, theme);

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColorLight.withOpacity(0.15),
        borderRadius: isLast
            ? BorderRadius.vertical(
                bottom: Radius.circular(borderRadiusFactor(4)),
              )
            : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isLast) _verticalLine(verticalLineColor),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onVisit(location, context),
                        child: BodyText1.light('I visited it!'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(borderRadiusFactor(2)),
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onSkip(location, context),
                        child: BodyText1(
                          'Skip',
                          color: theme.accentColor,
                        ),
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                            theme.accentColor.withOpacity(0.2),
                          ),
                          side: MaterialStateProperty.all(
                            BorderSide(color: theme.accentColor),
                          ),
                          shape: MaterialStateProperty.all(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _separator(
    LocationState state,
    ThemeData theme,
  ) {
    final verticalLineColor = colorFromLocationState(state, theme);

    return Container(
      height: spacingFactor(1),
      alignment: Alignment.centerLeft,
      child: _verticalLine(verticalLineColor),
    );
  }

  Widget _verticalLine(Color color) {
    return Container(
      margin: EdgeInsets.only(left: (56 - 4) / 2 + spacingFactor(1)),
      width: 4,
      color: color,
    );
  }

  _onNavigate() {
    this.onNavigate(location);
  }

  _onViewLocation() {
    onViewLocation(location);
  }

  _onRemove() {
    onRemove(location);
  }

  _onStartFromLocation() {
    onStartFromLocation(location);
  }
}
