import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/location.dart';

const INITIAL_ZOOM = 10.0;
const PLACE_ZOOM = 13.0;

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
  final Function(CameraPosition) onCameraMove;

  const TripMap({
    Key key,
    @required this.locations,
    @required this.currentLocationIndex,
    this.onMapCreated,
    this.onCameraMove,
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
      onCameraMove: onCameraMove,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Set<Marker> _markers() {
    Set<Marker> markers = Set();

    const hueMap = {
      0: BitmapDescriptor.hueBlue,
      1: BitmapDescriptor.hueViolet,
      2: BitmapDescriptor.hueAzure,
      3: BitmapDescriptor.hueOrange,
      4: BitmapDescriptor.hueRose,
      5: BitmapDescriptor.hueAzure
    };

    for (var i = 0; i < locations.length; i++) {
      final location = locations[i];
      var icon;

      if (currentLocationIndex == i) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      } else if (location.visitedAt != null) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      } else if (location.skipped != null && location.skipped) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      } else {
        icon = BitmapDescriptor.defaultMarkerWithHue(hueMap[location.dayIndex]);
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

    for (var i = 0; i < locations.length - 1; i++) {
      final point1 = locations[i];
      final point2 = locations[i + 1];

      if (point1.dayIndex != point2.dayIndex) {
        continue;
      }
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
}
