import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/small-icon-button.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/providers/questionnaire.dart';
import 'package:mywonderbird/providers/swipe-filters.dart';
import 'package:mywonderbird/providers/swipe.dart';
import 'package:mywonderbird/routes/suggested-trip/main.dart';
import 'package:mywonderbird/routes/swipe-locations/components/selected-locations.dart';
import 'package:mywonderbird/routes/swipe-locations/models/filters.dart';
import 'package:mywonderbird/routes/swipe-locations/pages/filters/main.dart';
import 'package:mywonderbird/routes/swipe-locations/pages/location-list/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/suggestion.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';

import 'components/animated-card.dart';
import 'components/first-card.dart';
import 'pages/location-details/main.dart';

const LOCATIONS_LOADED = 3;
const DEFAULT_PAGE_SIZE = 5;

class SwipeLocations extends StatefulWidget {
  @override
  _SwipeLocationsState createState() => _SwipeLocationsState();
}

class _SwipeLocationsState extends State<SwipeLocations> {
  final _animatedCardController = AnimatedCardController();
  final _storyController = StoryController();
  List<SuggestedLocation> _allLocations;
  List<SuggestedLocation> _locations;
  var _currentLocationIndex = 0;
  var _isLoading = true;

  var _hasMore = true;
  var _page = 0;

  SuggestedLocation get _currentLocation =>
      _locations.isNotEmpty ? _locations[_locations.length - 1] : null;

  List<SuggestedLocation> get _locationSublist {
    return _allLocations
        .sublist(
          _currentLocationIndex,
          min(
            _currentLocationIndex + LOCATIONS_LOADED,
            _allLocations.length,
          ),
        )
        .reversed
        .toList();
  }

  _fetchInitial() async {
    setState(() {
      _isLoading = true;
    });

    final suggestionService = locator<SuggestionService>();
    final swipeFiltersProvider = locator<SwipeFiltersProvider>();
    final locations = await suggestionService.suggestLocations(
      page: 0,
      pageSize: DEFAULT_PAGE_SIZE,
      tags: swipeFiltersProvider.selectedTags,
    );

    setState(() {
      _page = 1;
      _currentLocationIndex = 0;
      _hasMore = locations.length >= DEFAULT_PAGE_SIZE;
      _isLoading = false;
      _allLocations = locations;
      _locations = _locationSublist;
    });
  }

  _fetchMore() async {
    final suggestionService = locator<SuggestionService>();
    final swipeFiltersProvider = locator<SwipeFiltersProvider>();
    final locations = await suggestionService.suggestLocations(
      page: _page,
      pageSize: DEFAULT_PAGE_SIZE,
      tags: swipeFiltersProvider.selectedTags,
    );

    setState(() {
      _page++;
      _hasMore = locations.length >= DEFAULT_PAGE_SIZE;
      _allLocations = [
        ..._allLocations,
        ...locations,
      ];
      _locations = _locationSublist;
    });
  }

  _onFilterChange() async {
    await _fetchInitial();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final swipeProvider = locator<SwipeFiltersProvider>();
      swipeProvider.addListener(_onFilterChange);

      await _fetchInitial();
      _locations = _locationSublist;
    });
  }

  @override
  void dispose() {
    final swipeProvider = locator<SwipeFiltersProvider>();
    swipeProvider.removeListener(_onFilterChange);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return new Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final swipeProvider = Provider.of<SwipeProvider>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectedLocations(
          selectedLocations: swipeProvider.selectedLocations,
          viewLocations: _onViewLocations,
          filterLocations: _onFilterLocations,
          selectTerritory: () {},
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: _cards(),
          ),
        ),
        _actions(),
      ],
    );
  }

  List<Widget> _cards() {
    final List<Widget> cardWidgets = [];
    final width = MediaQuery.of(context).size.width;

    for (var i = 0; i < _locations.length; i++) {
      if (i == _locations.length - 1) {
        cardWidgets.add(
          AnimatedCard(
            controller: _animatedCardController,
            dismissLeft: _dismissLeft,
            dismissRight: _dismissRight,
            width: width,
            child: _card(context, i, storyView: true),
          ),
        );
      } else {
        cardWidgets.add(_card(context, i));
      }
    }

    return cardWidgets;
  }

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      child: SizedBox(
        height: 68,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FloatingActionButton(
              onPressed: _onBack,
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              child: BackButtonIcon(),
              heroTag: null,
              mini: true,
            ),
            Align(
              alignment: Alignment.center,
              child: FloatingActionButton(
                onPressed: _onDismiss,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                heroTag: null,
                child: Icon(
                  Icons.close,
                  size: 32,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: FloatingActionButton(
                onPressed: _onSelect,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                heroTag: null,
                child: Icon(
                  Icons.check,
                  size: 32,
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: _onReset,
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              heroTag: null,
              mini: true,
              child: Icon(
                Icons.refresh,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, int index, {bool storyView = false}) {
    final item = _locations[index];

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (storyView && item.images.length > 1)
            FirstCard(
              images: item.images,
              storyController: _storyController,
            )
          else if (item.images.isNotEmpty && item.images.first.url != null)
            Image.network(
              item.images.first.url,
              fit: BoxFit.cover,
            )
          else
            Container(
              color: Colors.grey,
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black38],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _locationDetails(item),
          ),
        ],
      ),
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    );
  }

  Widget _locationDetails(SuggestedLocation item) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                H6.light(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                ),
                Subtitle2.light(
                  item.country,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SmallIconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 32.0,
            ),
            onTap: _onViewDetails,
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
    );
  }

  _onViewDetails() {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => LocationDetails(location: _currentLocation),
    ));

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: LOCATION_INFO_SWIPING, parameters: {
      'location_id': _currentLocation.id,
      'location_name': _currentLocation.name,
      'location_country_code': _currentLocation.countryCode,
    });
  }

  _onViewLocations() {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => LocationList(
        removeLocation: _onRemoveLocation,
        clearLocations: _onClearLocations,
      ),
    ));
  }

  _onFilterLocations() async {
    final navigationService = locator<NavigationService>();
    final swipeFiltersProvider = locator<SwipeFiltersProvider>();

    final FiltersModel newFilters = await navigationService.push(
      MaterialPageRoute(
        builder: (context) => SwipeFilters(),
      ),
    );

    if (newFilters != null) {
      swipeFiltersProvider.selectedTags = newFilters.tags;
    }
  }

  _onRemoveLocation(int index) {
    final swipeProvider = locator<SwipeProvider>();

    swipeProvider.removeLocation(index);
  }

  _onClearLocations() {
    final swipeProvider = locator<SwipeProvider>();

    swipeProvider.clearLocations();
  }

  _dismissLeft() {
    _logSwipeEvent(DISLIKE_SWIPING);
    setState(() {
      _currentLocationIndex += 1;
      _locations = _locationSublist;
    });

    if (_hasMore) {
      if (_currentLocationIndex + LOCATIONS_LOADED >= _allLocations.length) {
        _fetchMore();
      }
    } else if (_currentLocationIndex >= _allLocations.length) {
      print('Finished');
    }
  }

  _dismissRight() {
    final swipeProvider = locator<SwipeProvider>();

    swipeProvider.selectLocation(_currentLocation);
    _logSwipeEvent(LIKE_SWIPING);

    setState(() {
      _currentLocationIndex += 1;
      _locations = _locationSublist;
    });

    // final questionnaireProvider = locator<QuestionnaireProvider>();

    // final duration = (questionnaireProvider.qValues['duration']) as int;
    // final locationCount =
    //     (questionnaireProvider.qValues['locationCount']) as int;

    if (_hasMore) {
      if (_currentLocationIndex + LOCATIONS_LOADED >= _allLocations.length) {
        _fetchMore();
      }
    } else if (_currentLocationIndex >= _allLocations.length) {
      print('Finished');
    }
  }

  _next() async {
    final swipeProvider = locator<SwipeProvider>();
    final locations = swipeProvider.selectedLocations;

    if (locations.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
            'We cannot suggest a trip. Please select some locations that you like!',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                final navigationService = locator<NavigationService>();
                navigationService.pop();
              },
              child: Text('OK!'),
            ),
          ],
        ),
      );

      _onReset();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final questionnaireProvider = locator<QuestionnaireProvider>();
    final navigationService = locator<NavigationService>();
    final suggestionService = locator<SuggestionService>();

    final duration = (questionnaireProvider.qValues['duration']) as int;
    final locationCount =
        (questionnaireProvider.qValues['locationCount']) as int;
    final locationIds = locations
        .sublist(0, duration * locationCount)
        .map((location) => location.id)
        .toList();
    final suggestedJourney =
        await suggestionService.suggestJourneyFromLocations(locationIds);

    try {
      final analytics = locator<FirebaseAnalytics>();
      analytics.logEvent(name: FINISH_SWIPING);

      await navigationService.push(
        MaterialPageRoute(
          builder: (context) => SuggestedTrip(
            suggestedJourney: suggestedJourney,
          ),
        ),
      );

      _onReset(logEvent: false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _onBack() {
    final navigationService = locator<NavigationService>();
    navigationService.pop();

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: CANCEL_SWIPING);
  }

  _onDismiss() {
    _animatedCardController.swipeLeft();
  }

  _onSelect() {
    _animatedCardController.swipeRight();
  }

  _onReset({logEvent: true}) {
    final swipeProvider = locator<SwipeProvider>();

    swipeProvider.clearLocations();
    setState(() {
      _currentLocationIndex = 0;
      _locations = _locationSublist;
      _isLoading = false;
    });

    if (logEvent) {
      final analytics = locator<FirebaseAnalytics>();
      analytics.logEvent(name: RESET_SWIPING);
    }
  }

  _logSwipeEvent(eventName) async {
    final analytics = locator<FirebaseAnalytics>();
    await analytics.logEvent(name: eventName, parameters: {
      'location_id': _currentLocation.id,
      'location_name': _currentLocation.name,
      'location_country_code': _currentLocation.countryCode,
    });
  }
}
