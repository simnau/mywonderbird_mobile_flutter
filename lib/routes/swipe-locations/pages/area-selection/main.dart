import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/providers/swipe-filters.dart';
import 'package:mywonderbird/routes/swipe-locations/components/area-selection-actions.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/util/location.dart';

import '../../main.dart';

class AreaSelection extends StatefulWidget {
  @override
  _AreaSelectionState createState() => _AreaSelectionState();
}

class _AreaSelectionState extends State<AreaSelection> {
  GoogleMapController mapController;

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
}
