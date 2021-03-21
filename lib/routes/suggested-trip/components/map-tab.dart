import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/util/geo.dart';

class MapTab extends StatefulWidget {
  final List<SuggestedLocation> locations;

  const MapTab({
    Key key,
    this.locations,
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

    return GoogleMap(
      markers: _markers(),
      polylines: _lines(),
      mapType: MapType.hybrid,
      initialCameraPosition: _INITIAL_CAMERA_POSITION,
      onMapCreated: _onMapCreated,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Set<Marker> _markers() {
    Set<Marker> markers = Set();

    for (var i = 0; i < widget.locations.length; i++) {
      markers.add(Marker(
        markerId: MarkerId("Marker-$i"),
        position: widget.locations[i].latLng,
        icon: BitmapDescriptor.defaultMarker,
        consumeTapEvents: true,
      ));
    }

    return markers;
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

    Future.delayed(
      Duration(milliseconds: 200),
      () {
        if (_tripBounds != null) {
          controller.moveCamera(
            CameraUpdate.newLatLngBounds(_tripBounds, 64.0),
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
