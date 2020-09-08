import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/location.dart';
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
  static const _INITIAL_ZOOM = 6.4;
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
              mapType: MapType.satellite,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    child: Text(
                      'Locations',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
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
    final theme = Theme.of(context);
    final location = _locations[index];

    return Dismissible(
      key: UniqueKey(),
      background: Container(color: theme.accentColor),
      onDismissed: (direction) => setState(() {
        _locations.removeAt(index);
      }),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
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
        title: Text(
          location.name,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    Future.delayed(
      Duration(milliseconds: 200),
      () => controller.moveCamera(
        CameraUpdate.newLatLngBounds(
          widget.bounds,
          64,
        ),
      ),
    );
  }
}
