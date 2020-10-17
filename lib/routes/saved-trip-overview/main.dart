import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/routes/saved-trip-finished/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/saved-trip.dart';
import 'package:mywonderbird/util/geo.dart';

import 'components/trip-map.dart';
import 'components/trip-slides.dart';

class SavedTripOverview extends StatefulWidget {
  final String id;

  const SavedTripOverview({
    Key key,
    @required this.id,
  }) : super(key: key);

  @override
  _SavedTripState createState() => _SavedTripState();
}

class _SavedTripState extends State<SavedTripOverview> {
  bool _isLoading = false;
  FullJourney _journey;
  GoogleMapController _mapController;
  PageController _pageController;
  LatLngBounds _tripBounds;
  int _currentPage;
  double _currentZoom;

  int get _currentLocationIndex => locationIndexFromPage(_currentPage);
  bool get _isLastLocation {
    return _currentLocationIndex == _journey.locations.length - 1;
  }

  int get _currentNonSkippedIndex {
    if (_journey == null || _currentPage == 0) {
      return 0;
    }

    int skippedLocationCount = _journey.locations
        .getRange(0, _currentLocationIndex)
        .where((element) => element.skipped != null && element.skipped)
        .length;

    return _currentLocationIndex - skippedLocationCount;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadJourney());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: TripMap(
              locations: _journey?.locations,
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              currentLocationIndex: _currentNonSkippedIndex,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black87,
                    width: 4.0,
                  ),
                ),
              ),
              child: TripSlides(
                journey: _journey,
                pageController: _pageController,
                onPageChanged: _onPageChanged,
                onStart: _onStart,
                onSkip: (location) => _onSkip(location, context),
                onUploadPhoto: (location) => _onUploadPhoto(location, context),
                onVisited: (location) => _onVisited(location, context),
                onNavigate: (location) => _onNavigate(location, context),
              ),
            ),
          )
        ],
      ),
    );
  }

  _loadJourney() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final savedTripService = locator<SavedTripService>();
      final navigationService = locator<NavigationService>();
      final savedJourney = await savedTripService.fetch(widget.id);

      if (savedJourney.finishDate != null) {
        navigationService.pushReplacement(
          MaterialPageRoute(
            builder: (context) => SavedTripFinished(),
          ),
        );
      } else {
        final tripBounds = boundsFromLatLngList(
          savedJourney.locations.map((location) => location.latLng).toList(),
        );

        final startingPage = _findStartingPage(savedJourney);

        _pageController = PageController(initialPage: startingPage);
        _currentPage = startingPage;

        setState(() {
          _isLoading = false;
          _journey = savedJourney;
          _tripBounds = tripBounds;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _findStartingPage(FullJourney journey) {
    if (journey.startDate == null) {
      return 0;
    }

    var startingPage = 1;

    for (int i = 0; i < journey.locations.length; i++) {
      final location = journey.locations[i];

      if ((location.skipped == null || !location.skipped) &&
          location.visitedAt == null) {
        break;
      } else {
        startingPage += 1;
      }
    }

    return startingPage;
  }

  _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    var cameraUpdate;

    if (_currentPage == 0) {
      final center = boundsCenter(_tripBounds);

      if (center != null) {
        cameraUpdate = CameraUpdate.newLatLngZoom(center, INITIAL_ZOOM);
      }
    } else {
      int locationIndex = locationIndexFromPage(_currentPage);
      LocationModel location = _journey.locations[locationIndex];

      cameraUpdate = CameraUpdate.newLatLngZoom(
        location.latLng,
        _currentZoom ?? PLACE_ZOOM,
      );
    }

    Future.delayed(
      Duration(milliseconds: 200),
      () {
        if (cameraUpdate != null) {
          controller.moveCamera(cameraUpdate);
        }
      },
    );
  }

  _onCameraMove(CameraPosition cameraPosition) {
    if (cameraPosition.zoom != _currentZoom) {
      _currentZoom = cameraPosition.zoom;
    }
  }

  _onPageChanged(int page) async {
    var cameraUpdate;

    if (page == 0) {
      final center = boundsCenter(_tripBounds);
      if (center != null) {
        cameraUpdate = CameraUpdate.newLatLngZoom(center, INITIAL_ZOOM);
      }
    } else {
      int locationIndex = locationIndexFromPage(page);
      LocationModel location = _journey.locations[locationIndex];

      cameraUpdate = CameraUpdate.newLatLngZoom(
        location.latLng,
        _currentZoom ?? PLACE_ZOOM,
      );
    }

    if (cameraUpdate != null) {
      _mapController?.animateCamera(cameraUpdate);
    }

    setState(() {
      _currentPage = page;
    });
  }

  _onStart() async {
    final savedTripService = locator<SavedTripService>();

    await savedTripService.startTrip(_journey.id);
    _goToPage(1);
  }

  _onEnd() async {
    final savedTripService = locator<SavedTripService>();
    final navigationService = locator<NavigationService>();

    await savedTripService.endTrip(_journey.id);
    navigationService.pushReplacement(
      MaterialPageRoute(
        builder: (context) => SavedTripFinished(),
      ),
    );
  }

  _onSkip(LocationModel location, BuildContext context) async {
    final savedTripService = locator<SavedTripService>();
    await savedTripService.skipLocation(_journey.id, location.id);

    if (_isLastLocation) {
      _onEnd();
    } else {
      setState(() {
        _journey.locations[_currentLocationIndex].skipped = true;
        _goToPage(_currentPage + 1);
      });
    }
  }

  _onUploadPhoto(LocationModel location, BuildContext context) async {
    print('upload photo');
  }

  _onVisited(LocationModel location, BuildContext context) async {
    final savedTripService = locator<SavedTripService>();
    await savedTripService.visitLocation(_journey.id, location.id);

    if (_isLastLocation) {
      _onEnd();
    } else {
      setState(() {
        _journey.locations[_currentLocationIndex].visitedAt = DateTime.now();
        // _showUploadPhotoSnackbar(context);
        _goToPage(_currentPage + 1);
      });
    }
  }

  _onNavigate(LocationModel location, BuildContext context) async {
    await MapsLauncher.launchCoordinates(
      location.latLng.latitude,
      location.latLng.longitude,
      location.name,
    );
  }

  _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  _showUploadPhotoSnackbar(BuildContext context) async {
    final snackBar = SnackBar(
      content: Text('You visited this location! Upload a photo?'),
      action: SnackBarAction(
        label: 'Upload photo',
        textColor: Colors.green,
        onPressed: _uploadPhoto,
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  _uploadPhoto() async {
    print('upload photo');
  }
}