import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/routes/trip-details/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/util/geo.dart';
import 'package:transparent_image/transparent_image.dart';

class TripOverview extends StatefulWidget {
  final FullJourney journey;

  const TripOverview({
    Key key,
    this.journey,
  }) : super(key: key);

  @override
  _TripOverviewState createState() => _TripOverviewState();
}

class _TripOverviewState extends State<TripOverview> {
  static const _INITIAL_ZOOM = 3.0;
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
      widget.journey.locations.map((location) => location.latLng).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: widget.journey.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(widget.journey.imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black54,
              ],
              stops: [0, 0.6],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._journeyName(),
                ..._journeyCountry(),
                _map(),
                Padding(padding: const EdgeInsets.only(bottom: 16.0)),
                _picturePreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _map() {
    return AspectRatio(
      aspectRatio: 3 / 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: GoogleMap(
          markers: _markers(),
          polylines: _lines(),
          mapType: MapType.hybrid,
          initialCameraPosition: _INITIAL_CAMERA_POSITION,
          onMapCreated: _onMapCreated,
          mapToolbarEnabled: false,
          rotateGesturesEnabled: false,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: false,
          tiltGesturesEnabled: false,
          scrollGesturesEnabled: false,
        ),
      ),
    );
  }

  Widget _picturePreview() {
    final locations = widget.journey.showCaseLocations;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...locations
            .map<Widget>((location) => _pictureThumbnail(location.imageUrl))
            .toList(),
        if (widget.journey.hasMorePictures) _morePictures(),
      ],
    );
  }

  Widget _pictureThumbnail(String url) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: url,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _morePictures() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(16.0),
      ),
      width: 72,
      height: 72,
      alignment: Alignment.center,
      child: Text(
        "+${widget.journey.morePictureCount}",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _journeyName() {
    if (widget.journey.name == null) {
      return [];
    }

    return [
      GestureDetector(
        onTap: _tripDetails,
        child: Row(
          children: [
            Expanded(child: H6.light(widget.journey.name)),
            Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 36.0,
            ),
          ],
        ),
      ),
      Padding(padding: const EdgeInsets.only(bottom: 16.0)),
    ];
  }

  List<Widget> _journeyCountry() {
    if (widget.journey.countryDescription == null) {
      return [];
    }

    return [
      Subtitle2.light(
        widget.journey.countryDescription,
        softWrap: true,
      ),
      Padding(padding: const EdgeInsets.only(bottom: 16.0)),
    ];
  }

  Set<Marker> _markers() {
    Set<Marker> markers = Set();

    for (var i = 0; i < widget.journey.locations.length; i++) {
      markers.add(Marker(
        markerId: MarkerId("Marker-$i"),
        position: widget.journey.locations[i].latLng,
        icon: BitmapDescriptor.defaultMarker,
        consumeTapEvents: true,
      ));
    }

    return markers;
  }

  Set<Polyline> _lines() {
    Set<Polyline> polylines = Set();

    for (var i = 0; i < widget.journey.locations.length - 1; i++) {
      final point1 = widget.journey.locations[i].latLng;
      final point2 = widget.journey.locations[i + 1].latLng;

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

  _tripDetails() {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => TripDetails(
        journey: widget.journey,
        bounds: _tripBounds,
      ),
    ));
  }

  _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    final center = boundsCenter(_tripBounds);

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
