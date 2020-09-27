import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/util/geo.dart';
import 'package:transparent_image/transparent_image.dart';

class TripDetails extends StatefulWidget {
  final FullJourney journey;
  final LatLngBounds bounds;

  const TripDetails({
    Key key,
    this.journey,
    this.bounds,
  }) : super(key: key);

  @override
  _TripDetailsState createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  static const _INITIAL_ZOOM = 3.0;
  static const _INITIAL_CAMERA_POSITION = CameraPosition(
    target: LatLng(
      63.791580,
      -17.352658,
    ),
    zoom: _INITIAL_ZOOM,
  );

  Completer<GoogleMapController> _mapController = Completer();
  List<LocationModel> _locations;

  @override
  void initState() {
    super.initState();
    _locations = List.from(widget.journey.locations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: _INITIAL_CAMERA_POSITION,
              polylines: _lines(),
              markers: _markers(),
              onMapCreated: _onMapCreated,
              mapToolbarEnabled: false,
              rotateGesturesEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, -4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Container(
                color: Color(0xFFF2F3F7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                      child: Subtitle1('Locations'),
                    ),
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                        ),
                        padding: const EdgeInsets.all(0),
                        itemBuilder: (context, index) => _item(index),
                        itemCount: _locations.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _markers() {
    Set<Marker> markers = Set();

    for (var i = 0; i < _locations.length; i++) {
      markers.add(Marker(
        markerId: MarkerId("Marker-$i"),
        position: _locations[i].latLng,
        icon: BitmapDescriptor.defaultMarker,
        consumeTapEvents: true,
      ));
    }

    return markers;
  }

  Set<Polyline> _lines() {
    Set<Polyline> polylines = Set();

    for (var i = 0; i < _locations.length - 1; i++) {
      final point1 = _locations[i].latLng;
      final point2 = _locations[i + 1].latLng;

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

  Widget _item(index) {
    final location = _locations[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 8.0,
          ),
          leading: AspectRatio(
            aspectRatio: 1,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: location.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Subtitle1(location.name),
        ),
      ),
    );
  }

  _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    final center = boundsCenter(widget.bounds);

    Future.delayed(
      Duration(milliseconds: 200),
      () {
        if (center != null) {
          controller.moveCamera(
            CameraUpdate.newLatLngZoom(center, _INITIAL_ZOOM),
          );
        }
      },
    );
  }
}
