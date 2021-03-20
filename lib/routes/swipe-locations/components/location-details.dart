import 'package:flutter/material.dart';
import 'package:mywonderbird/components/small-icon-button.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/models/suggested-location.dart';

class LocationDetails extends StatelessWidget {
  final SuggestedLocation item;
  final void Function() onTap;

  const LocationDetails({
    Key key,
    @required this.item,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                H6.light(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                ),
                Subtitle2.light(
                  item.country,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SmallIconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 32.0,
            ),
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
    );
  }
}
