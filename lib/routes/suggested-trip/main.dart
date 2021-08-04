import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/components/input-title-dialog.dart';
import 'package:mywonderbird/components/trip/vertical-split-view.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/suggested-journey.dart';
import 'package:mywonderbird/providers/saved-trips.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/saved-trip-location.dart';
import 'package:mywonderbird/models/saved-trip.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/providers/swipe.dart';
import 'package:mywonderbird/routes/profile/main.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/routes/swipe-locations/pages/location-details/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/saved-trip.dart';
import 'package:mywonderbird/services/suggestion.dart';
import 'package:mywonderbird/util/geo.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const LOCATIONS_TAB_INDEX = 0;
const MAP_TAB_INDEX = 1;

class SuggestedTrip extends StatefulWidget {
  final List<SuggestedLocation> locations;

  const SuggestedTrip({
    Key key,
    @required this.locations,
  }) : super(key: key);

  @override
  _SuggestedTripState createState() => _SuggestedTripState();
}

class _SuggestedTripState extends State<SuggestedTrip>
    with TickerProviderStateMixin {
  ItemScrollController _itemScrollController = ItemScrollController();
  LatLngBounds _tripBounds;
  GoogleMapController _mapController;
  List<SuggestedLocation> _locations = [];
  SuggestedJourney _suggestedTrip;
  double _currentZoom;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getJourneySuggestion(widget.locations);
    });
  }

  getJourneySuggestion(List<SuggestedLocation> suggestedLocations) async {
    if (suggestedLocations.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final suggestionService = locator<SuggestionService>();
    final locationIds =
        suggestedLocations.map((location) => location.id).toList();

    final suggestedTrip =
        await suggestionService.suggestJourneyFromLocations(locationIds);
    final tripBounds = boundsFromLatLngList(
      suggestedTrip.locations.map((location) => location.latLng).toList(),
    );

    setState(() {
      _tripBounds = tripBounds;
      _suggestedTrip = suggestedTrip;
      _locations = List.from(suggestedTrip.locations);
      _isLoading = false;
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

    return VerticalSplitView<SuggestedLocation>(
      trip: _suggestedTrip,
      currentLocationIndex: null,
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      onSaveTrip: _onSaveTrip,
      onViewLocation: _onViewLocationDetails,
      itemScrollController: _itemScrollController,
      isSaved: false,
    );
  }

  _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _adjustMapCamera();
  }

  _onCameraMove(CameraPosition cameraPosition) {
    if (cameraPosition.zoom != _currentZoom) {
      _currentZoom = cameraPosition.zoom;
    }
  }

  _adjustMapCamera() {
    var cameraUpdate;

    if (_tripBounds != null) {
      cameraUpdate =
          CameraUpdate.newLatLngBounds(_tripBounds, spacingFactor(8));
    }

    Future.delayed(
      Duration(milliseconds: 200),
      () {
        if (cameraUpdate != null && _mapController != null) {
          _mapController.moveCamera(cameraUpdate);
        }
      },
    );
  }

  _onRemoveLocation(SuggestedLocation location) async {
    setState(() {
      _locations.remove(location);
    });
    await getJourneySuggestion(_locations);
  }

  _onSaveTrip() async {
    final title = await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InputTitleDialog(
          title: 'Give a name to your trip',
          hint: 'Trip name',
        ),
      ),
      barrierDismissible: true,
    );

    if (title != null) {
      await _saveTrip(title);
      final swipeProvider = locator<SwipeProvider>();
      swipeProvider.clearLocations();
    }
  }

  _saveTrip(String title) async {
    final savedTripService = locator<SavedTripService>();
    final navigationService = locator<NavigationService>();

    final savedTrip = await savedTripService.saveTrip(_createSavedTrip(title));

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: SAVE_SUGGESTED, parameters: {
      'saved_trip_id': savedTrip.id,
    });

    navigationService.popUntil((route) => route.isFirst);
    navigationService.pushNamed(Profile.PATH);
    await navigationService.push(MaterialPageRoute(
      builder: (context) => SavedTripOverview(
        id: savedTrip.id,
      ),
    ));

    final savedTripsProvider = locator<SavedTripsProvider>();
    await savedTripsProvider.loadUserSavedTrips();
  }

  _createSavedTrip(String title) {
    List<SavedTripLocation> savedTripLocations = [];

    for (int i = 0; i < _locations.length; i++) {
      final location = _locations[i];

      savedTripLocations.add(
        SavedTripLocation(placeId: location.id, sequenceNumber: i),
      );
    }

    return SavedTrip(
      title: title,
      countryCode: _suggestedTrip.countryCode,
      savedTripLocations: savedTripLocations,
    );
  }

  _onViewLocationDetails(SuggestedLocation location) {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => LocationDetails(
        location: location,
      ),
    ));

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: LOCATION_INFO_SUGGESTED_LIST, parameters: {
      'location_id': location.id,
      'location_name': location.name,
      'location_country_code': location.countryCode,
    });
  }

  _onReorder(
    int oldIndex,
    int newIndex,
  ) {
    setState(() {
      // These two lines are workarounds for ReorderableListView problems
      if (newIndex > _locations.length) {
        newIndex = _locations.length;
      }

      if (oldIndex < newIndex) {
        newIndex--;
      }

      final temp = _locations[oldIndex];
      _locations.remove(temp);
      _locations.insert(newIndex, temp);
    });
  }
}
