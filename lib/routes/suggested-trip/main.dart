import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/input-title-dialog.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/models/suggested-journey.dart';
import 'package:mywonderbird/providers/saved-trips.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/saved-trip-location.dart';
import 'package:mywonderbird/models/saved-trip.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/routes/profile/main.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/routes/swipe-locations/pages/location-details/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/saved-trip.dart';
import 'package:mywonderbird/extensions/text-theme.dart';
import 'package:mywonderbird/services/suggestion.dart';

import 'components/locations-tab.dart';
import 'components/map-tab.dart';

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
  final _tabBarKey = GlobalKey();
  TabController _tabController;
  List<SuggestedLocation> _locations = [];
  SuggestedJourney _suggestedTrip;
  bool _isLoading = true;

  _SuggestedTripState() {
    _tabController = TabController(length: 2, vsync: this);
  }

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

    setState(() {
      _suggestedTrip = suggestedTrip;
      _locations = List.from(suggestedTrip.locations);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: BackButtonIcon(),
          onPressed: _onBack,
        ),
        title: Subtitle1('Your trip is ready!'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _onSaveTrip,
            child: Text(
              'SAVE TRIP',
              style: TextStyle(
                color: theme.primaryColor,
              ),
            ),
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
        TabBar(
          key: _tabBarKey,
          controller: _tabController,
          labelColor: theme.accentColor,
          unselectedLabelColor: Colors.black45,
          onTap: _onTabTap,
          indicator: BoxDecoration(),
          tabs: [
            Tab(
              child: Text(
                'LOCATIONS',
                style: theme.textTheme.tab,
              ),
            ),
            Tab(
              child: Text(
                'MAP',
                style: theme.textTheme.tab,
              ),
            ),
          ],
        ),
        if (_isLoading && _suggestedTrip != null)
          LinearProgressIndicator(
            minHeight: 4,
            backgroundColor: Colors.transparent,
          )
        else
          SizedBox(height: 4),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              LocationsTab(
                locations: _locations,
                onRemoveLocation: _onRemoveLocation,
                isLoading: _isLoading,
                suggestedTrip: _suggestedTrip,
                onViewLocation: _onViewLocationDetails,
                onReorder: _onReorder,
              ),
              MapTab(
                locations: _locations,
                onRemoveLocation: _onRemoveLocation,
                isLoading: _isLoading,
                onViewLocation: _onViewLocationDetails,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _onBack() async {
    final navigationService = locator<NavigationService>();

    navigationService.pop();
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

  _onTabTap(value) {
    final analytics = locator<FirebaseAnalytics>();

    if (value == LOCATIONS_TAB_INDEX) {
      analytics.logEvent(name: LOCATIONS_SUGGESTED);
    } else if (value == MAP_TAB_INDEX) {
      analytics.logEvent(name: MAP_SUGGESTED);
    }
  }

  _onViewLocationDetails(
    SuggestedLocation location,
    String event,
  ) {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => LocationDetails(
        location: location,
      ),
    ));

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: event, parameters: {
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
