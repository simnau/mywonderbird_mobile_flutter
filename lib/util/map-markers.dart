import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:ui' as ui;

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      .buffer
      .asUint8List();
}

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
  final Uint8List markerIcon = await getBytesFromAsset(
    "images/map-markers/$name",
    128,
  );

  return BitmapDescriptor.fromBytes(markerIcon);
}
