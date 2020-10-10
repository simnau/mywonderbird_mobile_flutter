import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/location.dart';

const INITIAL_ZOOM = 3.0;
const PLACE_ZOOM = 6.0;

class TripMap extends StatelessWidget {
  static const _INITIAL_CAMERA_POSITION = CameraPosition(
    target: LatLng(
      63.791580,
      -17.352658,
    ),
    zoom: INITIAL_ZOOM,
  );

  final List<LocationModel> locations;
  final int currentLocationIndex;
  final Function(GoogleMapController) onMapCreated;

  List<LocationModel> get nonSkippedLocations => locations
      .where((element) => element.skipped == null || !element.skipped)
      .toList();

  const TripMap({
    Key key,
    @required this.locations,
    @required this.currentLocationIndex,
    this.onMapCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (locations == null) {
      return Container();
    }

    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: _INITIAL_CAMERA_POSITION,
      polylines: _lines(),
      markers: _markers(),
      onMapCreated: onMapCreated,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Set<Marker> _markers() {
    Set<Marker> markers = Set();

    for (var i = 0; i < nonSkippedLocations.length; i++) {
      final location = nonSkippedLocations[i];
      var icon;

      if (currentLocationIndex == i) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      } else if (location.visitedAt != null) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      } else {
        icon = BitmapDescriptor.defaultMarker;
      }

      markers.add(Marker(
        markerId: MarkerId("Marker-$i"),
        position: location.latLng,
        icon: icon,
        consumeTapEvents: true,
      ));
    }

    return markers;
  }

  Set<Polyline> _lines() {
    Set<Polyline> polylines = Set();

    for (var i = 0; i < nonSkippedLocations.length - 1; i++) {
      final point1 = nonSkippedLocations[i].latLng;
      final point2 = nonSkippedLocations[i + 1].latLng;

      polylines.add(Polyline(
        polylineId: PolylineId("Polyline-$i"),
        width: 1,
        visible: true,
        color: Colors.white,
        jointType: JointType.bevel,
        patterns: [PatternItem.dash(12), PatternItem.gap(12)],
        points: [point1, point2],
      ));
    }

    return polylines;
  }
}
