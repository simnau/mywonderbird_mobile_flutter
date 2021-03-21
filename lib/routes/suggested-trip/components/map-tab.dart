import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/routes/suggested-trip/components/location-details.dart';
import 'package:mywonderbird/util/geo.dart';

class MapTab extends StatefulWidget {
  final List<SuggestedLocation> locations;
  final void Function(SuggestedLocation) onRemoveLocation;
  final bool isLoading;

  const MapTab({
    Key key,
    @required this.locations,
    @required this.onRemoveLocation,
    @required this.isLoading,
  }) : super(key: key);

  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab>
    with AutomaticKeepAliveClientMixin<MapTab> {
  static const _INITIAL_ZOOM = 11.0;
  static const _INITIAL_CAMERA_POSITION = CameraPosition(
    target: LatLng(
      63.791580,
      -17.352658,
    ),
    zoom: _INITIAL_ZOOM,
  );

  Completer<GoogleMapController> _mapController = Completer();
  LatLngBounds _tripBounds;
  SuggestedLocation _selectedLocation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tripBounds = boundsFromLatLngList(
      widget.locations.map((location) => location.latLng).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        GoogleMap(
          markers: _markers(),
          polylines: _lines(),
          mapType: MapType.hybrid,
          initialCameraPosition: _INITIAL_CAMERA_POSITION,
          onMapCreated: _onMapCreated,
          mapToolbarEnabled: false,
          rotateGesturesEnabled: false,
          zoomControlsEnabled: false,
          onTap: _onMapTap,
        ),
        if (_selectedLocation != null)
          Positioned(
            child: _locationDetails(),
            bottom: 0,
            left: 0,
            right: 0,
          ),
      ],
    );
  }

  Set<Marker> _markers() {
    return widget.locations.map(
      (location) {
        return Marker(
          markerId: MarkerId(location.id),
          position: location.latLng,
          icon: _selectedLocation?.id == location.id
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
              : BitmapDescriptor.defaultMarker,
          onTap: widget.isLoading ? null : () => _onMarkerTap(location),
        );
      },
    ).toSet();
  }

  Set<Polyline> _lines() {
    Set<Polyline> polylines = Set();
    var locationIndex = 0;

    for (var i = 0; i < widget.locations.length - 1; i++) {
      final point1 = widget.locations[i];
      final point2 = widget.locations[i + 1];

      if (locationIndex >= widget.locations.length) {
        locationIndex = 0;
        continue;
      }

      locationIndex++;

      polylines.add(Polyline(
        polylineId: PolylineId("Polyline-$i"),
        width: 1,
        visible: true,
        color: Colors.white,
        jointType: JointType.bevel,
        patterns: [PatternItem.dash(12), PatternItem.gap(12)],
        points: [point1.latLng, point2.latLng],
      ));
    }

    return polylines;
  }

  _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    if (_tripBounds != null) {
      Future.delayed(
        Duration(milliseconds: 100),
        () {
          controller.moveCamera(
            CameraUpdate.newLatLngBounds(_tripBounds, 64.0),
          );
        },
      );
    }
  }

  _onMapTap(_) async {
    setState(() {
      _selectedLocation = null;
    });
  }

  _onMarkerTap(SuggestedLocation location) async {
    setState(() {
      _selectedLocation = location;
    });
  }

  _onRemoveLocation(SuggestedLocation location) {
    widget.onRemoveLocation(location);
    setState(() {
      _selectedLocation = null;
    });
  }

  Widget _locationDetails() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, -4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: SuggestedTripLocationDetails(
          location: _selectedLocation,
          onRemoveLocation: _onRemoveLocation,
          isLoading: widget.isLoading,
        ),
      ),
    );
  }
}
