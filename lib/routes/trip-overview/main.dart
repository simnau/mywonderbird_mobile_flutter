import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/routes/trip-details/main.dart';
import 'package:mywonderbird/services/journeys.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/util/geo.dart';
import 'package:transparent_image/transparent_image.dart';

class TripOverview extends StatefulWidget {
  final String id;

  const TripOverview({
    Key key,
    @required this.id,
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

  bool _isLoading = true;
  FullJourney _journey;
  Completer<GoogleMapController> _mapController = Completer();
  LatLngBounds _tripBounds;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadJourney();
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = _isLoading || _journey.locations.isEmpty
        ? null
        : IconThemeData(color: Colors.white);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: iconTheme,
      ),
      extendBodyBehindAppBar: true,
      body: _body(),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_journey.locations.isEmpty) {
      return EmptyListPlaceholder(
        title: 'This trip has no locations',
        subtitle: 'Share locations to this trip to view them',
      );
    }

    return Container(
      decoration: BoxDecoration(
        image: _journey.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(_journey.imageUrl),
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
    final locations = _journey.showCaseLocations;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...locations
            .map<Widget>((location) => _pictureThumbnail(location.imageUrl))
            .toList(),
        if (_journey.hasMorePictures) _morePictures(),
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
        "+${_journey.morePictureCount}",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _journeyName() {
    if (_journey.name == null) {
      return [];
    }

    return [
      GestureDetector(
        onTap: _tripDetails,
        child: Row(
          children: [
            Expanded(child: H6.light(_journey.name)),
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
    if (_journey.countryDescription == null) {
      return [];
    }

    return [
      Subtitle2.light(
        _journey.countryDescription,
        softWrap: true,
      ),
      Padding(padding: const EdgeInsets.only(bottom: 16.0)),
    ];
  }

  _loadJourney() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final journeyService = locator<JourneyService>();
      final journey = await journeyService.getJourney(widget.id);

      final tripBounds = journey.locations.isEmpty
          ? null
          : boundsFromLatLngList(
              journey.locations.map((location) => location.latLng).toList(),
            );

      setState(() {
        _isLoading = false;
        _journey = journey;
        _tripBounds = tripBounds;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Set<Marker> _markers() {
    Set<Marker> markers = Set();

    for (var i = 0; i < _journey.locations.length; i++) {
      markers.add(Marker(
        markerId: MarkerId("Marker-$i"),
        position: _journey.locations[i].latLng,
        icon: BitmapDescriptor.defaultMarker,
        consumeTapEvents: true,
      ));
    }

    return markers;
  }

  Set<Polyline> _lines() {
    Set<Polyline> polylines = Set();

    for (var i = 0; i < _journey.locations.length - 1; i++) {
      final point1 = _journey.locations[i];
      final point2 = _journey.locations[i + 1];

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

  _tripDetails() {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => TripDetails(
        journey: _journey,
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
