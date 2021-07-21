import 'package:flutter/material.dart';
import 'package:mywonderbird/components/square-icon-button.dart';
import 'package:mywonderbird/components/trip/location-image.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/location.dart';
import 'location-state.dart';

class LocationItem extends StatelessWidget {
  final LocationModel location;
  final bool isFirst;
  final bool isLast;
  final double spacing;
  final int number;
  final Function() onTap;
  final bool isActive;
  final Function(LocationModel, BuildContext) onSkip;
  final Function(LocationModel, BuildContext) onVisit;

  const LocationItem({
    Key key,
    @required this.location,
    @required this.isFirst,
    @required this.isLast,
    @required this.spacing,
    @required this.number,
    this.onTap,
    this.isActive,
    this.onSkip,
    this.onVisit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderRadius = BorderRadius.vertical(
      top: Radius.circular(isFirst ? borderRadiusFactor(4) : 0),
      bottom: Radius.circular(isLast ? borderRadiusFactor(4) : 0),
    );
    final padding = EdgeInsets.fromLTRB(
      spacing,
      isFirst ? spacing : 0,
      spacing,
      isLast ? spacing : 0,
    );
    final state = isActive
        ? LocationState.active
        : location?.skipped ?? false
            ? LocationState.skipped
            : location.visitedAt != null
                ? LocationState.visited
                : null;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isActive ? theme.primaryColor : theme.primaryColorLight,
            borderRadius: borderRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
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
                  trailing: isActive
                      ? SquareIconButton(
                          size: 32,
                          icon: Icon(Icons.directions),
                          onPressed: () {},
                          backgroundColor: theme.primaryColorDark,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        if (state == LocationState.active)
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColorLight.withOpacity(0.5),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: (56 - 4) / 2 + spacingFactor(1),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 4,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => onVisit(location, context),
                            child: BodyText1.light('Visit'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              elevation: 0,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          OutlinedButton(
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
                          // OutlinedButton(
                          //   onPressed: () {},
                          //   child: BodyText1('Share photo'),
                          //   style: OutlinedButton.styleFrom(
                          //     shape: const RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.all(
                          //         Radius.circular(8.0),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }
}
