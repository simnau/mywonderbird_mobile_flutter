import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/providers/swipe-filters.dart';
import 'package:mywonderbird/providers/swipe.dart';
import 'package:mywonderbird/routes/swipe-locations/components/area-selection-actions.dart';
import 'package:mywonderbird/routes/swipe-locations/components/area-selection-location-slider.dart';
import 'package:mywonderbird/routes/swipe-locations/models/area-selection-suggested-location.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/suggestion.dart';
import 'package:mywonderbird/util/debouncer.dart';
import 'package:mywonderbird/util/location.dart';

import '../../main.dart';

class AreaSelection extends StatefulWidget {
  @override
  _AreaSelectionState createState() => _AreaSelectionState();
}

class _AreaSelectionState extends State<AreaSelection> {
  final _searchDebouncer = Debouncer(milliseconds: 50);

  GoogleMapController mapController;
  List<SuggestedLocation> _suggestedLocations;
  List<AreaSelectionSuggestedLocation> _locations;
  bool isLoading = true;
  LatLngBounds bounds;
  bool showLocationSlider = true;
  int currentLocationIndex = 0;

  fetchLocations({
    LatLng southWest,
    LatLng northEast,
  }) {
    _searchDebouncer.run(() async {
      setState(() {
        isLoading = true;
      });

      final suggestionService = locator<SuggestionService>();
      final swipeFiltersProvider = locator<SwipeFiltersProvider>();

      final suggestedLocations = await suggestionService.suggestLocations(
        page: 0,
        pageSize: 15,
        tags: swipeFiltersProvider.selectedTags,
        northEast: northEast ?? swipeFiltersProvider.northEast,
        southWest: southWest ?? swipeFiltersProvider.southWest,
      );

      setState(() {
        isLoading = false;
        _locations = _allLocations(suggestedLocations);
        _suggestedLocations = suggestedLocations;
      });
    });
  }

  @override
  initState() {
    super.initState();

    final swipeProvider = locator<SwipeProvider>();

    swipeProvider.addListener(_updateLocations);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLocations();
    });
  }

  @override
  dispose() {
    final swipeProvider = locator<SwipeProvider>();

    swipeProvider.removeListener(_updateLocations);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _body(context),
      extendBodyBehindAppBar: true,
    );
  }

  Widget _body(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: CameraPosition(
            zoom: INITIAL_ZOOM,
            target: LatLng(0, 0),
          ),
          mapToolbarEnabled: false,
          rotateGesturesEnabled: false,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: _onMapCreated,
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
          onTap: _onMapTap,
          markers: _markers(),
        ),
        _bottomActions(),
      ],
    );
  }

  Positioned _bottomActions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 16.0),
              child: AreaSelectionActions(
                onSelectArea: _onSelectArea,
                onGoToMyLocation: _onGoToMyLocation,
              ),
            ),
            if (showLocationSlider &&
                _locations != null &&
                _locations.isNotEmpty)
              AreaSelectionLocationSlider(
                locations: _locations,
                addLocation: _addLocation,
                removeLocation: _removeLocation,
                onLocationChange: _onLocationChange,
              ),
          ],
        ),
      ),
    );
  }

  Set<Marker> _markers() {
    if (_locations == null) {
      return Set.identity();
    }

    final markers = Set<Marker>();

    for (var index = 0; index < _locations.length; index++) {
      final location = _locations[index];
      final isHighlighted = currentLocationIndex == index;

      final marker = Marker(
        markerId: MarkerId(location.id),
        position: location.latLng,
        icon: isHighlighted
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
            : location.isSelected
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue)
                : BitmapDescriptor.defaultMarker,
      );

      markers.add(marker);
    }

    return markers;
  }

  _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    final swipeFiltersProvider = locator<SwipeFiltersProvider>();

    Future.delayed(
      Duration(milliseconds: 100),
      () => mapController.moveCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: swipeFiltersProvider.southWest,
            northeast: swipeFiltersProvider.northEast,
          ),
          0.0,
        ),
      ),
    );
  }

  _onSelectArea() async {
    if (mapController != null) {
      final visibleRegion = await mapController.getVisibleRegion();

      final navigationService = locator<NavigationService>();
      navigationService.pop(visibleRegion);
    }
  }

  _onGoToMyLocation() async {
    final currentLocation = await getCurrentLocation();
    final newLatLng = LatLng(
      currentLocation.latitude,
      currentLocation.longitude,
    );

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(newLatLng));
    }
  }

  _onCameraIdle() {
    fetchLocations(
      southWest: bounds?.southwest,
      northEast: bounds?.northeast,
    );
  }

  _onCameraMove(CameraPosition position) async {
    _searchDebouncer.cancel();
    bounds = await mapController.getVisibleRegion();
  }

  _onMapTap(_) {
    setState(() {
      showLocationSlider = !showLocationSlider;
    });
  }

  List<AreaSelectionSuggestedLocation> _allLocations(
      List<SuggestedLocation> suggestedLocations) {
    final swipeProvider = locator<SwipeProvider>();

    final List<AreaSelectionSuggestedLocation> locations = [];

    for (final suggestedLocation in suggestedLocations) {
      final index = swipeProvider.selectedLocations
          .indexWhere((location) => location.id == suggestedLocation.id);

      locations.add(AreaSelectionSuggestedLocation(
        isSelected: index >= 0,
        suggestedLocation: suggestedLocation,
      ));
    }

    return locations;
  }

  _updateLocations() {
    setState(() {
      _locations = _allLocations(_suggestedLocations);
    });
  }

  _addLocation(SuggestedLocation suggestedLocation) {
    final swipeProvider = locator<SwipeProvider>();

    swipeProvider.selectLocation(suggestedLocation);
  }

  _removeLocation(SuggestedLocation suggestedLocation) {
    final swipeProvider = locator<SwipeProvider>();

    swipeProvider.removeLocation(suggestedLocation);
  }

  _onLocationChange(int index) {
    setState(() {
      currentLocationIndex = index;
    });
  }
}
