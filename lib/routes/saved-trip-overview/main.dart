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
import 'package:mywonderbird/routes/details/pages/system-location-details.dart';
import 'package:mywonderbird/routes/saved-trip-finished/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/saved-trip.dart';
import 'package:mywonderbird/util/geo.dart';
import 'package:mywonderbird/util/location.dart';
import 'package:mywonderbird/util/map-markers.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'components/trip-map.dart';

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
  ItemScrollController _itemScrollController = ItemScrollController();
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isRecalculatingRoute = false;
  FullJourney _journey;
  GoogleMapController _mapController;
  LatLngBounds _tripBounds;
  int _currentLocationIndex;
  double _currentZoom;
  List<LocationModel> _temporaryEditLocations;

  bool get _isLastLocation {
    return _currentLocationIndex == _journey.locations.length - 1;
  }

  bool get _isTripStarted => _journey?.startDate != null;

  LocationModel get _selectedLocation => _currentLocationIndex >= 0 &&
          _currentLocationIndex < _journey.locations.length
      ? _journey.locations[_currentLocationIndex]
      : null;

  List<LocationModel> get _locations =>
      _isEditing ? _temporaryEditLocations : _journey?.locations;

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

    return VerticalSplitView<LocationModel>(
      trip: _journey,
      locations: _locations,
      currentLocationIndex: _currentLocationIndex,
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      onGoToMyLocation: _onGoToMyLocation,
      onViewLocation: _onViewLocation,
      onStart: _onStart,
      onSkip: _onSkip,
      onVisit: _onVisited,
      onNavigate: _onNavigate,
      itemScrollController: _itemScrollController,
      isSaved: true,
      isEditing: _isEditing,
      isRecalculatingRoute: _isRecalculatingRoute,
      onEdit: _onEdit,
      onRemove: _onRemoveLocation,
      onCancelEdit: _onCancelEdit,
      onSaveEdit: _onSaveEdit,
      onStartFromLocation: _onStartFromLocation,
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
            builder: (context) => SavedTripFinished(id: widget.id),
          ),
        );
      } else {
        final tripBounds = boundsFromLatLngList(
          savedJourney.locations.map((location) => location.latLng).toList(),
        );

        final startingLocation = _findStartingLocation(savedJourney);

        _currentLocationIndex = startingLocation;

        await ensureMarkersAreAvailable(savedJourney.locations.length);

        setState(() {
          _isLoading = false;
          _journey = savedJourney;
          _tripBounds = tripBounds;
        });

        _animateToLocation(_currentLocationIndex);
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _findStartingLocation(FullJourney journey) {
    if (journey.startDate == null) {
      return 0;
    }

    var startingLocation = 0;

    for (int i = 0; i < journey.locations.length; i++) {
      final location = journey.locations[i];

      if ((location.skipped == null || !location.skipped) &&
          location.visitedAt == null) {
        break;
      } else {
        startingLocation += 1;
      }
    }

    return startingLocation;
  }

  _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _adjustMapCamera();
  }

  _adjustMapCamera({final bool animateCamera = false}) {
    var cameraUpdate;

    if (!_isTripStarted) {
      if (_locations.length == 1) {
        cameraUpdate = CameraUpdate.newLatLngZoom(
          _locations.first?.latLng,
          PLACE_ZOOM,
        );
      } else if (_tripBounds != null) {
        cameraUpdate =
            CameraUpdate.newLatLngBounds(_tripBounds, spacingFactor(8));
      }
    } else {
      cameraUpdate = CameraUpdate.newLatLngZoom(
        _selectedLocation?.latLng,
        _currentZoom ?? PLACE_ZOOM,
      );
    }

    Future.delayed(
      Duration(milliseconds: 200),
      () {
        if (cameraUpdate != null && _mapController != null) {
          if (animateCamera) {
            _mapController.animateCamera(cameraUpdate);
          } else {
            _mapController.moveCamera(cameraUpdate);
          }
        }
      },
    );
  }

  _adjustCameraToLocation(
    LocationModel location, {
    final bool animateCamera = false,
  }) {
    final cameraUpdate = CameraUpdate.newLatLngZoom(
      location?.latLng,
      _currentZoom ?? PLACE_ZOOM,
    );

    if (animateCamera) {
      _mapController.animateCamera(cameraUpdate);
    } else {
      _mapController.moveCamera(cameraUpdate);
    }
  }

  _onCameraMove(CameraPosition cameraPosition) {
    // FIXME: this seems to set the zoom level inappropriately
    // if (cameraPosition.zoom != _currentZoom) {
    //   _currentZoom = cameraPosition.zoom;
    // }
  }

  _onGoToMyLocation() async {
    final currentLocation = await getCurrentLocation();
    final newLatLng = LatLng(
      currentLocation.latitude,
      currentLocation.longitude,
    );

    if (_mapController != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(newLatLng));
    }
  }

  _onViewLocation(LocationModel location) {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => SystemLocationDetails(
        locationId: location.placeId,
      ),
    ));

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: LOCATION_INFO_SAVED_LIST, parameters: {
      'location_id': location.id,
      'location_name': location.name,
      'location_country_code': location.countryCode,
    });
  }

  _onStart() async {
    final savedTripService = locator<SavedTripService>();

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: START_SAVED, parameters: {
      'saved_trip_id': widget.id,
    });

    await savedTripService.startTrip(_journey.id);
    setState(() {
      _journey.startDate = DateTime.now();
      _currentZoom = null;
    });
    _goToLocation(0);
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
        _selectedLocation.skipped = true;
        _goToLocation(_currentLocationIndex + 1);
      });
    }
  }

  // TODO: implement and use this
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
        _selectedLocation.visitedAt = DateTime.now();

        // TODO: do we want to show a snackbar after we upload a photo so it's less intrusive?
        // _showUploadPhotoSnackbar(context);
        _goToLocation(_currentLocationIndex + 1);
      });
    }
  }

  _onNavigate(LocationModel location) async {
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

  _goToLocation(int newLocation) {
    setState(() {
      _currentLocationIndex = newLocation;
    });
    _animateToLocation(newLocation);
  }

  _animateToLocation(int locationIndex) {
    Future.delayed(
      Duration(milliseconds: 200),
      () {
        _itemScrollController.scrollTo(
          index: locationIndex,
          duration: Duration(milliseconds: 400),
        );
      },
    );

    _adjustMapCamera(animateCamera: true);
  }

  _onRemoveLocation(LocationModel location) {
    // Do not allow removal of skipped/visited locations
    if ((location?.skipped != null && location.skipped) ||
        location?.visitedAt != null) {
      return;
    }

    setState(() {
      _temporaryEditLocations.remove(location);
    });
  }

  _onEdit() {
    setState(() {
      _temporaryEditLocations = List.from(_journey.locations);
      _isEditing = true;
    });
  }

  _onSaveEdit() async {
    if (_temporaryEditLocations.isEmpty) {
      final snackBar = createErrorSnackbar(
        text: 'Your trip should include at least 1 location',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      await updateTrip(_temporaryEditLocations);
    }

    setState(() {
      _isEditing = false;
      _temporaryEditLocations = null;
    });
  }

  _onCancelEdit() {
    setState(() {
      _isEditing = false;
      _temporaryEditLocations = null;
    });
  }

  _onStartFromLocation(LocationModel location) async {
    setState(() {
      _isRecalculatingRoute = true;
    });

    final suggestionService = locator<SavedTripService>();
    final suggestedTrip = await suggestionService.startTripAtLocation(
      _journey.id,
      location.placeId,
    );

    setState(() {
      _journey = suggestedTrip;
      _isRecalculatingRoute = false;
    });

    if (_isTripStarted) {
      _adjustCameraToLocation(
        suggestedTrip.locations[_currentLocationIndex],
        animateCamera: true,
      );
    }
  }

  updateTrip(List<LocationModel> newLocations) async {
    final savedTripService = locator<SavedTripService>();
    final updatedTrip = await savedTripService.updateTripLocations(
      _journey.id,
      newLocations,
    );

    final tripBounds = boundsFromLatLngList(
      updatedTrip.locations.map((location) => location.latLng).toList(),
    );

    setState(() {
      _journey = updatedTrip;
      _tripBounds = tripBounds;
    });

    if (_currentLocationIndex >= updatedTrip.locations.length) {
      _onEnd();
    } else {
      _adjustMapCamera(animateCamera: true);
    }
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
