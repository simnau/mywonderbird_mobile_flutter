import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:mywonderbird/components/trip/vertical-split-view.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/routes/saved-trip-finished/main.dart';
import 'package:mywonderbird/routes/swipe-locations/pages/location-details/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/saved-trip.dart';
import 'package:mywonderbird/util/converters/suggested-location.dart';
import 'package:mywonderbird/util/geo.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Permission.location.request();
      _loadJourney();

      final analytics = locator<FirebaseAnalytics>();
      analytics.logEvent(name: OPEN_SAVED, parameters: {
        'saved_trip_id': widget.id,
      });
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     extendBodyBehindAppBar: true,
  //     appBar: AppBar(
  //       backgroundColor: Colors.transparent,
  //       iconTheme: IconThemeData(color: Colors.white),
  //     ),
  //     body: _body(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _body(),
      backgroundColor: Colors.white,
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return VerticalSplitView(
      trip: _journey,
      locations: _journey?.locations,
      currentLocationIndex: _currentLocationIndex,
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      onViewLocation: _onViewLocation,
    );
  }

  // Widget _body() {
  //   if (_isLoading) {
  //     return Center(
  //       child: CircularProgressIndicator(),
  //     );
  //   }

  //   return Builder(
  //     builder: (context) => Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         AspectRatio(
  //           aspectRatio: 3 / 2,
  //           child: TripMap(
  //             locations: _journey?.locations,
  //             onMapCreated: _onMapCreated,
  //             onCameraMove: _onCameraMove,
  //             currentLocationIndex: _currentLocationIndex,
  //           ),
  //         ),
  //         Expanded(
  //           child: Container(
  //             decoration: BoxDecoration(
  //               border: Border(
  //                 top: BorderSide(
  //                   color: Colors.black87,
  //                   width: 4.0,
  //                 ),
  //               ),
  //             ),
  //             child: TripSlides(
  //               journey: _journey,
  //               pageController: _pageController,
  //               onPageChanged: _onPageChanged,
  //               onStart: _onStart,
  //               onSkip: (location) => _onSkip(location, context),
  //               onUploadPhoto: (location) => _onUploadPhoto(location, context),
  //               onVisited: (location) => _onVisited(location, context),
  //               onNavigate: (location) => _onNavigate(location, context),
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

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
            builder: (context) => SavedTripFinished(id: widget.id),
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
      if (_tripBounds != null) {
        cameraUpdate =
            CameraUpdate.newLatLngBounds(_tripBounds, spacingFactor(8));
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

  _onViewLocation(LocationModel location) {
    final navigationService = locator<NavigationService>();
    final suggestedLocationConverter = locator<SuggestedLocationConverter>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => LocationDetails(
        location: suggestedLocationConverter.convertFrom(location),
      ),
    ));

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: LOCATION_INFO_SAVED_LIST, parameters: {
      'location_id': location.id,
      'location_name': location.name,
      'location_country_code': location.countryCode,
    });
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

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: START_SAVED, parameters: {
      'saved_trip_id': widget.id,
    });

    await savedTripService.startTrip(_journey.id);
    _goToPage(1);
  }

  _onEnd() async {
    final savedTripService = locator<SavedTripService>();
    final navigationService = locator<NavigationService>();

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: FINISH_SAVED, parameters: {
      'saved_trip_id': widget.id,
    });

    await savedTripService.endTrip(_journey.id);
    navigationService.pushReplacement(
      MaterialPageRoute(
        builder: (context) => SavedTripFinished(id: widget.id),
      ),
    );
  }

  _onSkip(LocationModel location, BuildContext context) async {
    final savedTripService = locator<SavedTripService>();
    await savedTripService.skipLocation(_journey.id, location.id);

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: SKIP_LOCATION_SAVED, parameters: {
      'saved_trip_id': widget.id,
      'saved_location_id': location.id,
      'saved_location_name': location.name,
    });

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
    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: ADD_PHOTO_SAVED, parameters: {
      'saved_trip_id': widget.id,
      'saved_location_id': location.id,
      'saved_location_name': location.name,
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Subtitle1('Coming soon!'),
          content: SingleChildScrollView(
            child: BodyText1(
              'You will be able to upload photos from your trip soon. Stay tuned!',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _onVisited(LocationModel location, BuildContext context) async {
    final savedTripService = locator<SavedTripService>();
    await savedTripService.visitLocation(_journey.id, location.id);

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: VISIT_LOCATION_SAVED, parameters: {
      'saved_trip_id': widget.id,
      'saved_location_id': location.id,
      'saved_location_name': location.name,
    });

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
    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: NAVIGATE_TO_LOCATION_SAVED, parameters: {
      'saved_trip_id': widget.id,
      'saved_location_id': location.id,
      'saved_location_name': location.name,
    });

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

  // TODO: either makes this work or remove it if we deem it unnecessary
  // _showUploadPhotoSnackbar(BuildContext context) async {
  //   final snackBar = SnackBar(
  //     content: Text('You visited this location! Upload a photo?'),
  //     action: SnackBarAction(
  //       label: 'Upload photo',
  //       textColor: Colors.green,
  //       onPressed: _uploadPhoto,
  //     ),
  //   );

  //   Scaffold.of(context).showSnackBar(snackBar);
  // }

  // _uploadPhoto() async {
  //   final analytics = locator<FirebaseAnalytics>();
  //   analytics.logEvent(name: ADD_PHOTO_SAVED, parameters: {
  //     'saved_trip_id': widget.id,
  //   });
  // }
}
