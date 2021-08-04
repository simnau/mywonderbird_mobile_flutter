import 'package:flutter/material.dart';
import 'package:mywonderbird/components/trip/location-item.dart';
import 'package:mywonderbird/components/trip/location-state.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TripDetails<T extends LocationModel> extends StatefulWidget {
  final FullJourney trip;
  final int currentLocationIndex;
  final Function(T) onViewLocation;
  final ItemScrollController itemScrollController;
  final Function() onSaveTrip;
  final Function() onStart;
  final Function(T, BuildContext) onSkip;
  final Function(T, BuildContext) onVisit;
  final Function(T) onNavigate;
  final bool isSaved;

  TripDetails({
    Key key,
    @required this.trip,
    @required this.currentLocationIndex,
    @required this.onViewLocation,
    @required this.onSaveTrip,
    @required this.onStart,
    @required this.onSkip,
    @required this.onVisit,
    @required this.onNavigate,
    @required this.isSaved,
    this.itemScrollController,
  }) : super(key: key);

  @override
  _TripDetailsState<T> createState() => _TripDetailsState<T>();
}

class _TripDetailsState<T extends LocationModel> extends State<TripDetails<T>> {
  bool showFullTripName = false;

  bool get isTripStarted => widget.trip?.startDate != null;
  List<T> get locations => widget.trip?.locations;

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
              widget.isSaved
                  ? widget.trip?.name ?? 'Loading...'
                  : 'Your trip is ready!',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(borderRadiusFactor(2)),
                ),
              ),
            ),
          ),
        ),
        if (widget.trip?.startDate != null) Expanded(child: SizedBox()),
        if (widget.trip?.startDate == null || !widget.isSaved)
          SizedBox(width: spacingFactor(2)),
        if (widget.isSaved && widget.trip?.startDate == null)
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onStart,
              child: BodyText1.light('Start'),
              style: ElevatedButton.styleFrom(
                primary: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(borderRadiusFactor(2)),
                  ),
                ),
                elevation: 0,
              ),
            ),
          ),
        if (!widget.isSaved)
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onSaveTrip,
              child: BodyText1.light('Save trip'),
              style: ElevatedButton.styleFrom(
                primary: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(borderRadiusFactor(2)),
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
        final location = locations[index];
        final isFirst = index == 0;
        final isLast = index == locations.length - 1;
        final previousLocation = isFirst ? null : locations[index - 1];
        final isActive = isTripStarted && index == widget.currentLocationIndex;
        final isLastLocationActive =
            isTripStarted && index - 1 == widget.currentLocationIndex;
        final previousLocationState = previousLocation != null
            ? locationStateFromLocation(
                previousLocation,
                isLastLocationActive,
              )
            : null;
        print(widget);

        return LocationItem<T>(
          location: location,
          isFirst: isFirst,
          isLast: isLast,
          number: index + 1,
          onViewLocation: widget.onViewLocation,
          isActive: isActive,
          previousLocationState: previousLocationState,
          onSkip: widget.onSkip,
          onVisit: widget.onVisit,
          onNavigate: widget.onNavigate,
        );
      },
      itemCount: locations?.length ?? 0,
    );
  }

  toggleShowFullTripName() {
    setState(() {
      showFullTripName = !showFullTripName;
    });
  }
}
