import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/input-title-dialog.dart';
import 'package:mywonderbird/components/small-icon-button.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/providers/questionnaire.dart';
import 'package:mywonderbird/routes/suggest-trip-questionnaire/steps.dart';
import 'package:quiver/iterables.dart';
import 'package:mywonderbird/components/typography/h5.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
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
  List<List<SuggestedLocation>> _suggestedLocationParts = [];

  _SuggestedTripState() {
    _tabController = TabController(length: 2, vsync: this);
  }

  bool get _isComplete {
    final questionnaireProvider = locator<QuestionnaireProvider>();

    final duration = questionnaireProvider.qValues['duration'];
    final locationCount = questionnaireProvider.qValues['locationCount'];
    final expectedCount = duration * locationCount;

    return _locations.length >= expectedCount;
  }

  @override
  void initState() {
    super.initState();

    final questionnaireProvider = locator<QuestionnaireProvider>();

    _locations = List.from(widget.suggestedJourney.locations);
    _suggestedLocationParts = partition<SuggestedLocation>(
            _locations, questionnaireProvider.qValues['locationCount'])
        .toList();
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
        H5('Your trip is ready!'),
        if (!_isComplete) _incompleteNotification(),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
        ),
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
                locations: _suggestedLocationParts,
                onRemoveLocation: _onRemoveLocation,
              ),
              MapTab(
                locations: _locations,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _incompleteNotification() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue[300], width: 1),
        color: Colors.blue[100],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showIncompleteAlert,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 24.0,
                ),
                Expanded(
                  child: BodyText1(
                    'We could not fill your trip',
                    textAlign: TextAlign.center,
                  ),
                ),
                SmallIconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.black87,
                    size: 24.0,
                  ),
                  padding: const EdgeInsets.all(6.0),
                  borderRadius: BorderRadius.circular(24.0),
                  onTap: _showIncompleteAlert,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showIncompleteAlert() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Subtitle1('We could not fill your trip'),
          content: SingleChildScrollView(
            child: BodyText1(
              'We were unable to fill your trip as we do not have enough locations that suit you. Try selecting more locations',
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

  _onRemoveLocation(int index) {
    setState(() {
      _locations.removeAt(index);
    });
  }

  _onSaveTrip() async {
    final title = await showDialog(
      context: context,
      child: Dialog(
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
    final questionnaireProvider = locator<QuestionnaireProvider>();

    final savedTrip = await savedTripService.saveTrip(
        _createSavedTrip(title), stepValues(questionnaireProvider.qValues));

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: SAVE_SUGGESTED, parameters: {
      'saved_trip_id': savedTrip.id,
    });

    navigationService.popUntil((route) => route.isFirst);
    navigationService.pushNamed(Profile.PATH);
    navigationService.push(MaterialPageRoute(
      builder: (context) => SavedTripOverview(
        id: savedTrip.id,
      ),
    ));
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
