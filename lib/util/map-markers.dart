import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:ui' as ui;

import 'package:mywonderbird/components/markers/map-marker.dart';
import 'package:mywonderbird/util/color.dart';
import 'package:mywonderbird/util/widget-to-image.dart';

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
BitmapDescriptor moreThan99Marker;

Map<int, BitmapDescriptor> numberedMarkers = Map();

initMarkers() async {
  final results = await Future.wait([
    createMarkerFromWidget(MapMarker()),
    createMarkerFromWidget(
      MapMarker(
        icon: MaterialCommunityIcons.flag_variant,
        color: lighten(Colors.blue[500], amount: 0.05),
        decorationColor: lighten(Colors.blue[500], amount: 0.05),
      ),
    ),
    createMarkerFromWidget(
      MapMarker(
        icon: MaterialCommunityIcons.close,
        color: Colors.grey[400],
        decorationColor: Colors.grey[400],
      ),
    ),
    createMarkerFromWidget(
      MapMarker(
        icon: MaterialCommunityIcons.check_bold,
        color: Color(0xFF38D01F),
        decorationColor: Color(0xFF38D01F),
      ),
    ),
    createMarkerFromWidget(
      MapMarker(
        number: 100,
      ),
    ),
    createMarkerFromWidget(
      MapMarker(
        number: 1,
      ),
    ),
    createMarkerFromWidget(
      MapMarker(
        number: 2,
      ),
    ),
    createMarkerFromWidget(
      MapMarker(
        number: 3,
      ),
    ),
    createMarkerFromWidget(
      MapMarker(
        number: 4,
      ),
    ),
    createMarkerFromWidget(
      MapMarker(
        number: 5,
      ),
    ),
  ]);

  defaultMarker = results[0];
  currentMarker = results[1];
  skippedMarker = results[2];
  visitedMarker = results[3];
  moreThan99Marker = results[4];

  numberedMarkers[1] = results[5];
  numberedMarkers[2] = results[6];
  numberedMarkers[3] = results[7];
  numberedMarkers[4] = results[8];
  numberedMarkers[5] = results[9];
}

Future<BitmapDescriptor> createMarker(String name) async {
  final Uint8List markerIcon = await getBytesFromAsset(
    "images/map-markers/$name",
    128,
  );

  return BitmapDescriptor.fromBytes(markerIcon);
}

Future<BitmapDescriptor> createMarkerFromWidget(Widget widget) async {
  final bytes = await createImageFromWidget(widget,
      imageSize: Size(160, 160), logicalSize: Size(128, 128));

  return BitmapDescriptor.fromBytes(bytes);
}

ensureMarkersAreAvailable(int locationCount) async {
  final numbers = List<int>.generate(locationCount, (i) => i + 1);

  final markers = await Future.wait(
    numbers
        .map<Future<NumberedMarker>>(
          (number) async => ensureMarkerIsAvailable(number),
        )
        .toList(),
  );

  markers.where((element) => element != null).forEach((element) {
    numberedMarkers[element.number] = element.marker;
  });
}

Future<NumberedMarker> ensureMarkerIsAvailable(int number) async {
  final marker = numberedMarkers[number];

  if (marker != null) {
    return null;
  }

  final newMarker = await createMarkerFromWidget(
    MapMarker(
      number: number,
    ),
  );

  return NumberedMarker(
    number: number,
    marker: newMarker,
  );
}

class NumberedMarker {
  int number;
  BitmapDescriptor marker;

  NumberedMarker({
    this.number,
    this.marker,
  });
}
