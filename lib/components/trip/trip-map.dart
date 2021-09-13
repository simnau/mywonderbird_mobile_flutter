import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/components/square-icon-button.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/util/map-markers.dart';

const INITIAL_ZOOM = 10.0;
const PLACE_ZOOM = 13.0;

class TripMap<T extends LocationModel> extends StatelessWidget {
  static const _INITIAL_CAMERA_POSITION = CameraPosition(
    target: LatLng(
      63.791580,
      -17.352658,
    ),
    zoom: INITIAL_ZOOM,
  );

  final List<T> locations;
  final int currentLocationIndex;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition) onCameraMove;
  final Function() onGoToMyLocation;
  final bool isTripStarted;

  const TripMap({
    Key key,
    @required this.locations,
    @required this.currentLocationIndex,
    this.onMapCreated,
    this.onCameraMove,
    this.onGoToMyLocation,
    @required this.isTripStarted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (locations == null) {
      return Container();
    }

    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _INITIAL_CAMERA_POSITION,
          polylines: _lines(),
          markers: _markers(),
          onMapCreated: onMapCreated,
          onCameraMove: onCameraMove,
          mapToolbarEnabled: false,
          rotateGesturesEnabled: false,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        Positioned.directional(
          bottom: spacingFactor(2),
          end: spacingFactor(2),
          textDirection: TextDirection.ltr,
          child: SquareIconButton(
            size: 36,
            icon: Icon(
              Icons.my_location,
              color: Colors.black,
            ),
            onPressed: onGoToMyLocation,
            backgroundColor: Colors.grey[50].withOpacity(0.85),
          ),
        )
      ],
    );
  }

  Set<Marker> _markers() {
    Set<Marker> markers = Set();

    for (var i = 0; i < locations.length; i++) {
      final location = locations[i];
      var icon;

      if (isTripStarted && currentLocationIndex == i) {
        icon = currentMarker;
      } else if (location.visitedAt != null) {
        icon = visitedMarker;
      } else if (location.skipped != null && location.skipped) {
        icon = skippedMarker;
      } else if (i >= 99) {
        icon = moreThan99Marker;
      } else {
        icon = numberedMarkers[i + 1] ?? defaultMarker;
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
        width: 3,
        visible: true,
        color: Colors.white,
        jointType: JointType.bevel,
        points: [point1.latLng, point2.latLng],
      ));
    }

    return polylines;
  }
}
