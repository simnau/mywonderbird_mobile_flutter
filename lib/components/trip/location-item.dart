import 'package:flutter/material.dart';
import 'package:mywonderbird/components/trip/location-image.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/location.dart';

class LocationItem extends StatelessWidget {
  final LocationModel location;
  final bool isFirst;
  final bool isLast;
  final double spacing;
  final int number;
  final Function() onTap;

  const LocationItem({
    Key key,
    @required this.location,
    @required this.isFirst,
    @required this.isLast,
    @required this.spacing,
    @required this.number,
    this.onTap,
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

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColorLight,
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
              ),
              title: Subtitle1(
                location.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
