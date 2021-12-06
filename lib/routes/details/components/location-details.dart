import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/components/square-icon-button.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';

class LocationDetails<T extends LocationModel> extends StatefulWidget {
  final T location;

  const LocationDetails({
    Key key,
    @required this.location,
  }) : super(key: key);

  @override
  _LocationDetailsState createState() => _LocationDetailsState();
}

class _LocationDetailsState extends State<LocationDetails> {
  final storyController = StoryController();
  GoogleMapController mapController;
  bool isZoomedIn = false;

  bool get hasImage => widget.location.imageUrl != null;
  LatLng get getLoc => widget.location.latLng;
  String get getDescription => widget.location.description;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _locationMap(),
        if (!isZoomedIn)
          Positioned(
            height: MediaQuery.of(context).size.height / 2,
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: _imageDetails(),
          )
      ],
    );
  }

  Widget _locationMap() {
    const _INITIAL_ZOOM = 14.4746;
    final latitude = isZoomedIn ? getLoc.latitude : getLoc.latitude - 0.006;
    final longitude = getLoc.longitude;
    final initialCameraPosition = CameraPosition(
        target: LatLng(latitude, longitude), zoom: _INITIAL_ZOOM);
    final bottomPadding = isZoomedIn
        ? spacingFactor(2)
        : MediaQuery.of(context).size.height / 2 + spacingFactor(1);
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: initialCameraPosition,
          markers: Set.of([
            Marker(
              markerId: MarkerId('Location'),
              position: getLoc,
              icon: BitmapDescriptor.defaultMarker,
            )
          ]),
          mapToolbarEnabled: false,
          rotateGesturesEnabled: false,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: _onMapCreated,
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Opacity(
            opacity: 0.5,
            child: Container(
              height: kToolbarHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black,
                    Colors.black.withOpacity(0),
                  ],
                  stops: [0, 0.75, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
        ),
        Positioned.directional(
          bottom: bottomPadding,
          end: spacingFactor(2),
          textDirection: TextDirection.ltr,
          child: SquareIconButton(
            size: 36,
            icon: Icon(
              Icons.my_location,
              color: Colors.black,
            ),
            onPressed: _onGoToLocation,
            backgroundColor: Colors.grey[50].withOpacity(0.85),
          ),
        ),
        Positioned.directional(
          bottom: bottomPadding,
          end: spacingFactor(8),
          textDirection: TextDirection.ltr,
          child: SquareIconButton(
            size: 36,
            icon: Icon(
              isZoomedIn ? Icons.close_fullscreen : Icons.zoom_out_map,
              color: Colors.black,
            ),
            onPressed: _onExpand,
            backgroundColor: Colors.grey[50].withOpacity(0.85),
          ),
        )
      ],
    );
  }

  Widget _imageDetails() {
    return ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: Column(children: [
          Expanded(child: _image(), flex: 3),
          Expanded(child: _details(), flex: 2)
        ]));
  }

  Widget _image() {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 14 / 9,
            child: _imageContent(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Opacity(
              opacity: 0.5,
              child: Container(
                height: kToolbarHeight + 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.black,
                      Colors.black.withOpacity(0),
                    ],
                    stops: [0, 0.75, 1],
                  ),
                ),
              ),
            ),
          ),
          _locationName(),
        ],
      ),
    );
  }

  Widget _imageContent() {
    if (!hasImage) {
      return Container(color: Colors.grey);
    }

    if (widget.location.locationImages.length == 1) {
      return Container(
          color: Colors.white,
          child: Image.network(
            widget.location.locationImages.first,
            fit: BoxFit.cover,
          ));
    }

    return StoryView(
      controller: storyController,
      repeat: true,
      inline: true,
      storyItems: widget.location.locationImages.map((image) {
        return StoryItem.inlineProviderImage(
          NetworkImage(image),
          roundedTop: false,
          roundedBottom: false,
        );
      }).toList(),
    );
  }

  Widget _locationName() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Subtitle1(
            widget.location.name,
            softWrap: true,
            color: Colors.white,
          ),
          Padding(padding: const EdgeInsets.only(bottom: 4.0)),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              Padding(padding: const EdgeInsets.only(right: 4.0)),
              Subtitle2(
                widget.location.country,
                softWrap: true,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _details() {
    final description = getDescription;
    double width = MediaQuery.of(context).size.width * 0.9;

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Subtitle1(
              'About',
              softWrap: true,
            ),
            Padding(padding: const EdgeInsets.only(bottom: 8.0)),
            Row(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  width: width,
                  child: BodyText1(
                    description == null ? 'No description' : description,
                    softWrap: true,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onExpand() {
    setState(() {
      isZoomedIn = !isZoomedIn;
    });
    final newLatLng = LatLng(
      isZoomedIn ? getLoc.latitude : getLoc.latitude - 0.006,
      getLoc.longitude,
    );

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(newLatLng));
    }
  }

  _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    Future.delayed(
      Duration(milliseconds: 100),
      () => mapController.moveCamera(CameraUpdate.newLatLng(
          LatLng(getLoc.latitude - 0.006, getLoc.longitude))),
    );
  }

  _onGoToLocation() async {
    final newLatLng = LatLng(
      isZoomedIn ? getLoc.latitude : getLoc.latitude - 0.006,
      getLoc.longitude,
    );

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(newLatLng));
    }
  }
}
