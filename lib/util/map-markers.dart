import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

BitmapDescriptor defaultMarker;
BitmapDescriptor currentMarker;
BitmapDescriptor skippedMarker;
BitmapDescriptor visitedMarker;

initMarkers() async {
  final results = await Future.wait([
    createMarker('default.png'),
    createMarker('current.png'),
    createMarker('skipped.png'),
    createMarker('visited.png'),
  ]);

  defaultMarker = results[0];
  currentMarker = results[1];
  skippedMarker = results[2];
  visitedMarker = results[3];
}

Future<BitmapDescriptor> createMarker(String name) async {
  return BitmapDescriptor.fromAssetImage(
    ImageConfiguration(devicePixelRatio: 3),
    "images/map-markers/$name",
  );
}
