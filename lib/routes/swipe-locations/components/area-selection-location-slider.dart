import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/routes/swipe-locations/models/area-selection-suggested-location.dart';
import 'package:mywonderbird/routes/swipe-locations/models/current-index-update.dart';
import 'package:transparent_image/transparent_image.dart';

class AreaSelectionLocationSlider extends StatefulWidget {
  final int initialIndex;
  final List<AreaSelectionSuggestedLocation> locations;
  final ValueNotifier<CurrentIndexUpdate> currentLocationNotifier;
  final Function(SuggestedLocation) addLocation;
  final Function(SuggestedLocation) removeLocation;
  final Function(int) onLocationChange;
  final Function() onViewLocation;

  AreaSelectionLocationSlider({
    Key key,
    @required this.initialIndex,
    @required this.locations,
    @required this.currentLocationNotifier,
    @required this.addLocation,
    @required this.removeLocation,
    @required this.onLocationChange,
    @required this.onViewLocation,
  }) : super(key: key);

  @override
  _AreaSelectionLocationSliderState createState() =>
      _AreaSelectionLocationSliderState();
}

class _AreaSelectionLocationSliderState
    extends State<AreaSelectionLocationSlider> {
  PageController _pageController;

  bool disableLocationChange = false;

  @override
  initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    widget.currentLocationNotifier.addListener(_currentLocationChange);
  }

  @override
  dispose() {
    widget.currentLocationNotifier.removeListener(_currentLocationChange);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        onPageChanged: _onPageChange,
        children: widget.locations.map((location) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  spreadRadius: 4.0,
                )
              ],
            ),
            margin: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 32.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onViewLocation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _location(context, location),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _location(
    BuildContext context,
    AreaSelectionSuggestedLocation location,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: Subtitle1(
        location.name,
        overflow: TextOverflow.ellipsis,
      ),
      leading: AspectRatio(
        aspectRatio: 1,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.grey,
          ),
          child: location.coverImage != null
              ? FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: location.coverImage.url,
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          location.isSelected ? Icons.delete_forever : Icons.add_circle,
          color: location.isSelected ? Colors.red : theme.primaryColor,
          size: 32.0,
        ),
        onPressed: () => location.isSelected
            ? widget.removeLocation(location)
            : widget.addLocation(location),
      ),
    );
  }

  _onPageChange(int page) {
    if (!widget.currentLocationNotifier.value.disableSliderChange) {
      disableLocationChange = true;
    }
    widget.onLocationChange(page);
  }

  _currentLocationChange() {
    if (!disableLocationChange) {
      final currentIndex = widget.currentLocationNotifier.value.index;

      _pageController.jumpToPage(currentIndex);
    } else {
      disableLocationChange = false;
    }
  }
}
