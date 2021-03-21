import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/input-title-dialog.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/providers/saved-trips.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/saved-trip-location.dart';
import 'package:mywonderbird/models/saved-trip.dart';
import 'package:mywonderbird/models/suggested-journey.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/routes/profile/main.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/saved-trip.dart';
import 'package:mywonderbird/extensions/text-theme.dart';

import 'components/locations-tab.dart';
import 'components/map-tab.dart';

const LOCATIONS_TAB_INDEX = 0;
const MAP_TAB_INDEX = 1;

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
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              LocationsTab(
                locations: _locations,
                onRemoveLocation: _onRemoveLocation,
              ),
              MapTab(
                locations: _locations,
                onRemoveLocation: _onRemoveLocation,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _onBack() async {
    final navigationService = locator<NavigationService>();
    final theme = Theme.of(context);

    final onYes = () => navigationService.pop(true);
    final onNo = () => navigationService.pop(false);

    final shouldNavigate = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          'You will lose your trip if you go back. Do you want to continue?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: onYes,
            child: Text(
              'YES',
              style: TextStyle(
                color: theme.errorColor,
              ),
            ),
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  return theme.errorColor.withOpacity(0.2);
                },
              ),
            ),
          ),
          TextButton(
            onPressed: onNo,
            child: Text('NO'),
          ),
        ],
      ),
    );

    if (shouldNavigate != null && shouldNavigate) {
      navigationService.pop();
    }
  }

  _onRemoveLocation(SuggestedLocation location) {
    setState(() {
      _locations.remove(location);
    });
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

    for (int i = 0; i < widget.suggestedJourney.locations.length; i++) {
      final location = widget.suggestedJourney.locations[i];

      savedTripLocations.add(
        SavedTripLocation(placeId: location.id, sequenceNumber: i),
      );
    }

    return SavedTrip(
      title: title,
      countryCode: widget.suggestedJourney.countryCode,
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
}
