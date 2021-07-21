import 'package:flutter/material.dart';
import 'package:mywonderbird/components/trip/location-item.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TripDetails extends StatefulWidget {
  final FullJourney trip;
  final List<LocationModel> locations;
  final int currentLocationIndex;
  final Function(LocationModel) onViewLocation;
  final ItemScrollController itemScrollController;

  TripDetails({
    Key key,
    @required this.trip,
    @required this.locations,
    @required this.currentLocationIndex,
    @required this.onViewLocation,
    this.itemScrollController,
  }) : super(key: key);

  @override
  _TripDetailsState createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  bool showFullTripName = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacingFactor(4),
        vertical: spacingFactor(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: toggleShowFullTripName,
            child: H6(
              widget.trip?.name ?? 'Loading...',
              overflow: showFullTripName
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: spacingFactor(1)),
          _actions(),
          SizedBox(height: spacingFactor(2)),
          Expanded(
            child: _itemList(),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            child: BodyText1('Edit'),
            style: OutlinedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: spacingFactor(2)),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            child: BodyText1.light('Start'),
            style: ElevatedButton.styleFrom(
              primary: theme.primaryColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemList() {
    final theme = Theme.of(context);

    return ScrollablePositionedList.separated(
      itemScrollController: widget.itemScrollController,
      padding: const EdgeInsets.all(0),
      itemBuilder: (context, index) {
        final location = widget.locations[index];

        return LocationItem(
          location: location,
          isFirst: index == 0,
          isLast: index == widget.locations.length - 1,
          spacing: spacingFactor(1),
          number: index + 1,
          onTap: () => widget.onViewLocation(location),
        );
      },
      separatorBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(
            left: (56 - 4) / 2 + spacingFactor(1),
          ),
          alignment: Alignment.centerLeft,
          color: theme.primaryColorLight,
          child: Container(
            width: 4,
            height: 16,
            color: Colors.white,
          ),
        );
      },
      itemCount: widget.locations?.length ?? 0,
    );
  }

  toggleShowFullTripName() {
    setState(() {
      showFullTripName = !showFullTripName;
    });
  }
}
