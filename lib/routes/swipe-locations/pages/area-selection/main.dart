import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/providers/swipe-filters.dart';
import 'package:mywonderbird/providers/swipe.dart';
import 'package:mywonderbird/routes/swipe-locations/components/area-selection-actions.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/suggestion.dart';
import 'package:mywonderbird/util/debouncer.dart';
import 'package:mywonderbird/util/location.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class AreaSelection extends StatefulWidget {
  @override
  _AreaSelectionState createState() => _AreaSelectionState();
}

class _AreaSelectionState extends State<AreaSelection> {
  GoogleMapController mapController;
  List<SuggestedLocation> locations;
  bool isLoading = true;
  LatLngBounds bounds;
  final _searchDebouncer = Debouncer(milliseconds: 50);

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
        locations = _filterLocations(suggestedLocations);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLocations();
    });
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
          markers: _allMarkers(),
        ),
        Positioned(
          bottom: 32.0,
          left: 32.0,
          right: 32.0,
          child: AreaSelectionActions(
            onSelectArea: _onSelectArea,
            onGoToMyLocation: _onGoToMyLocation,
          ),
        ),
      ],
    );
  }

  Set<Marker> _locationMarkers() {
    if (locations == null) {
      return Set.identity();
    }

    return locations
        .map(
          (location) => Marker(
            markerId: MarkerId(location.id),
            position: location.latLng,
            icon: BitmapDescriptor.defaultMarker,
          ),
        )
        .toSet();
  }

  Set<Marker> _selectedMarkers() {
    final swipeProvider = Provider.of<SwipeProvider>(context);

    return swipeProvider.selectedLocations
        .map(
          (location) => Marker(
            markerId: MarkerId(location.id),
            position: location.latLng,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        )
        .toSet();
  }

  Set<Marker> _allMarkers() {
    final selectedMarkers = _selectedMarkers();
    final locationMarkers = _locationMarkers();

    return Set<Marker>()..addAll(selectedMarkers)..addAll(locationMarkers);
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

  List<SuggestedLocation> _filterLocations(
      List<SuggestedLocation> suggestedLocations) {
    final swipeProvider = locator<SwipeProvider>();

    return suggestedLocations.where((location) {
      final index = swipeProvider.selectedLocations
          .indexWhere((selectedLocation) => location.id == selectedLocation.id);
      return index < 0;
    }).toList();
  }
}
