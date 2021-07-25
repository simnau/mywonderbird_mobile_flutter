import 'package:flutter/material.dart';
import 'package:mywonderbird/components/trip/location-item.dart';
import 'package:mywonderbird/components/trip/location-state.dart';
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
  final Function() onStart;
  final Function(LocationModel, BuildContext) onSkip;
  final Function(LocationModel, BuildContext) onVisit;
  final Function(LocationModel) onNavigate;

  TripDetails({
    Key key,
    @required this.trip,
    @required this.locations,
    @required this.currentLocationIndex,
    @required this.onViewLocation,
    @required this.onStart,
    @required this.onSkip,
    @required this.onVisit,
    @required this.onNavigate,
    this.itemScrollController,
  }) : super(key: key);

  @override
  _TripDetailsState createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  bool showFullTripName = false;

  bool get isTripStarted => widget.trip?.startDate != null;

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
        if (widget.trip?.startDate != null) Expanded(child: SizedBox()),
        if (widget.trip?.startDate == null) SizedBox(width: spacingFactor(2)),
        if (widget.trip?.startDate == null)
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onStart,
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
    return ScrollablePositionedList.builder(
      itemScrollController: widget.itemScrollController,
      padding: const EdgeInsets.all(0),
      itemBuilder: (context, index) {
        final location = widget.locations[index];
        final isFirst = index == 0;
        final isLast = index == widget.locations.length - 1;
        final previousLocation = isFirst ? null : widget.locations[index - 1];
        final isActive = isTripStarted && index == widget.currentLocationIndex;
        final isLastLocationActive =
            isTripStarted && index - 1 == widget.currentLocationIndex;
        final previousLocationState = previousLocation != null
            ? locationStateFromLocation(
                previousLocation,
                isLastLocationActive,
              )
            : null;

        return LocationItem(
          location: location,
          isFirst: isFirst,
          isLast: isLast,
          number: index + 1,
          onTap: () => widget.onViewLocation(location),
          isActive: isActive,
          previousLocationState: previousLocationState,
          onSkip: widget.onSkip,
          onVisit: widget.onVisit,
          onNavigate: widget.onNavigate,
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
