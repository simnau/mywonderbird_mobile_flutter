import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/suggested-journey.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/util/geo.dart';
import 'package:transparent_image/transparent_image.dart';

class SuggestedTrip extends StatefulWidget {
  final SuggestedJourney suggestedJourney;

  const SuggestedTrip({
    Key key,
    @required this.suggestedJourney,
  }) : super(key: key);

  @override
  _SuggestedTripState createState() => _SuggestedTripState();
}

class _SuggestedTripState extends State<SuggestedTrip>
    with TickerProviderStateMixin {
  final _tabBarKey = GlobalKey();
  TabController _tabController;
  List<SuggestedLocation> _locations = [];

  _SuggestedTripState() {
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void initState() {
    super.initState();
    _locations = List.from(widget.suggestedJourney.locations);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          FlatButton(
            onPressed: _onSaveTrip,
            child: Text(
              'SAVE TRIP',
              style: TextStyle(
                color: theme.primaryColor,
              ),
            ),
            shape: ContinuousRectangleBorder(),
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Your trip is ready!',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
        ),
        TabBar(
          key: _tabBarKey,
          controller: _tabController,
          labelColor: theme.accentColor,
          unselectedLabelColor: Colors.black45,
          tabs: [
            Tab(
              child: Text(
                'LOCATIONS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Tab(
              child: Text(
                'MAP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _LocationsTab(
                locations: _locations,
                onRemoveLocation: _onRemoveLocation,
              ),
              _MapTab(
                locations: _locations,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _onRemoveLocation(int index) {
    setState(() {
      _locations.removeAt(index);
    });
  }

  _onSaveTrip() {}
}

class _LocationsTab extends StatelessWidget {
  final List<SuggestedLocation> locations;
  final Function(int) onRemoveLocation;

  const _LocationsTab({
    Key key,
    this.locations,
    this.onRemoveLocation,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: _location,
      itemCount: locations.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
      ),
    );
  }

  Widget _location(context, index) {
    final location = locations[index];
    final imageUrl = location.coverImage?.url;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 8.0,
        ),
        title: Text(
          location.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        leading: AspectRatio(
          aspectRatio: 1,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.grey,
            ),
            child: imageUrl != null
                ? FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: imageUrl,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_forever,
            color: Colors.red,
          ),
          onPressed: () => onRemoveLocation(index),
        ),
      ),
    );
  }
}

class _MapTab extends StatefulWidget {
  final List<SuggestedLocation> locations;

  const _MapTab({
    Key key,
    this.locations,
  }) : super(key: key);

  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<_MapTab>
    with AutomaticKeepAliveClientMixin<_MapTab> {
  static const _INITIAL_ZOOM = 6.0;
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
      widget.locations.map((location) => location.latLng).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GoogleMap(
      markers: _markers(),
      polylines: _lines(),
      mapType: MapType.hybrid,
      initialCameraPosition: _INITIAL_CAMERA_POSITION,
      onMapCreated: _onMapCreated,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Set<Marker> _markers() {
    Set<Marker> markers = Set();

    for (var i = 0; i < widget.locations.length; i++) {
      markers.add(Marker(
        markerId: MarkerId("Marker-$i"),
        position: widget.locations[i].latLng,
        icon: BitmapDescriptor.defaultMarker,
        consumeTapEvents: true,
      ));
    }

    return markers;
  }

  Set<Polyline> _lines() {
    Set<Polyline> polylines = Set();

    for (var i = 0; i < widget.locations.length - 1; i++) {
      final point1 = widget.locations[i].latLng;
      final point2 = widget.locations[i + 1].latLng;

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

  @override
  bool get wantKeepAlive => true;
}
