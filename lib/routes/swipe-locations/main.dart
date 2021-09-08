import 'dart:math';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/providers/swipe-filters.dart';
import 'package:mywonderbird/providers/swipe.dart';
import 'package:mywonderbird/routes/suggested-trip/main.dart';
import 'package:mywonderbird/routes/swipe-locations/components/selected-locations.dart';
import 'package:mywonderbird/routes/swipe-locations/components/swipe-actions.dart';
import 'package:mywonderbird/routes/swipe-locations/models/filters.dart';
import 'package:mywonderbird/routes/swipe-locations/pages/area-selection/main.dart';
import 'package:mywonderbird/routes/swipe-locations/pages/filters/main.dart';
import 'package:mywonderbird/routes/swipe-locations/pages/location-list/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/suggestion.dart';
import 'package:mywonderbird/util/geo.dart';
import 'package:mywonderbird/util/location.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';

import 'components/animated-card.dart';
import 'components/location-card.dart';
import 'pages/location-details/main.dart';

const LOCATIONS_LOADED = 3;
const DEFAULT_PAGE_SIZE = 5;
const INITIAL_ZOOM = 12.0;
const DEFAULT_CAMERA_POSITION = LatLng(
  63.791580,
  -17.352658,
);

const ADD_LOCATION_FEATURE = 'add_location_swipe';
const SKIP_LOCATION_FEATURE = 'skip_location_swipe';
const COMPLETE_PLANNING_FEATURE = 'complete_planning_swipe';
const SELECT_AREA_FEATURE = 'select_area_swipe';
const FILTER_LOCATIONS_FEATURE = 'filter_locations_swipe';

class SwipeLocations extends StatefulWidget {
  @override
  _SwipeLocationsState createState() => _SwipeLocationsState();
}

class _SwipeLocationsState extends State<SwipeLocations> {
  final _animatedCardController = AnimatedCardController();
  final _storyController = StoryController();
  List<SuggestedLocation> _allLocations;
  List<SuggestedLocation> _locations;
  LocationData _userLocation;
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
    final currentLocation = await getCurrentLocation();

    if (swipeFiltersProvider.northEast == null ||
        swipeFiltersProvider.southWest == null) {
      final screenSize = MediaQuery.of(context).size;
      final center = currentLocation != null
          ? LatLng(
              currentLocation.latitude,
              currentLocation.longitude,
            )
          : DEFAULT_CAMERA_POSITION;

      final bounds = getBounds(
        center,
        INITIAL_ZOOM,
        screenSize.width,
        screenSize.height,
      );

      swipeFiltersProvider.setBounds(
        bounds.southwest,
        bounds.northeast,
        notify: false,
      );
    }
    final swipeProvider = locator<SwipeProvider>();

    final locations = await suggestionService.suggestLocations(
      page: 0,
      pageSize: DEFAULT_PAGE_SIZE,
      tags: swipeFiltersProvider.selectedTags,
      southWest: swipeFiltersProvider.southWest,
      northEast: swipeFiltersProvider.northEast,
      selectedLocations: swipeProvider.selectedLocations,
    );

    setState(() {
      _page = 1;
      _currentLocationIndex = 0;
      _hasMore = locations.length >= DEFAULT_PAGE_SIZE;
      _isLoading = false;
      _allLocations = locations;
      _locations = _locationSublist;
      _userLocation = currentLocation;
    });
  }

  _fetchMore() async {
    final suggestionService = locator<SuggestionService>();
    final swipeFiltersProvider = locator<SwipeFiltersProvider>();
    final swipeProvider = locator<SwipeProvider>();
    final locations = await suggestionService.suggestLocations(
      page: _page,
      pageSize: DEFAULT_PAGE_SIZE,
      tags: swipeFiltersProvider.selectedTags,
      southWest: swipeFiltersProvider.southWest,
      northEast: swipeFiltersProvider.northEast,
      selectedLocations: swipeProvider.selectedLocations,
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
      FeatureDiscovery.discoverFeatures(context, <String>[
        ADD_LOCATION_FEATURE,
        SKIP_LOCATION_FEATURE,
        COMPLETE_PLANNING_FEATURE,
        FILTER_LOCATIONS_FEATURE,
        SELECT_AREA_FEATURE,
      ]);

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
          selectArea: _onSelectArea,
        ),
        SizedBox(height: 8.0),
        Expanded(child: _mainContent()),
        SwipeActions(
          onDismiss: _onDismiss,
          onSelect: _onSelect,
          onSave: _onSave,
        ),
      ],
    );
  }

  Widget _mainContent() {
    final theme = Theme.of(context);
    final buttonStyle = ButtonStyle(
      overlayColor: MaterialStateProperty.all(
        theme.accentColor.withOpacity(0.2),
      ),
      side: MaterialStateProperty.all(
        BorderSide(color: theme.accentColor),
      ),
    );

    final helperActions = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: _onFilterLocations,
          icon: Icon(
            FontAwesome.sliders,
            color: theme.accentColor,
          ),
          label: BodyText1('Change filters'),
          style: buttonStyle,
        ),
        SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _onSelectArea,
          icon: Icon(
            MaterialCommunityIcons.map_marker,
            color: theme.accentColor,
          ),
          label: BodyText1('Change area'),
          style: buttonStyle,
        ),
      ],
    );

    if (_locations.isEmpty && _allLocations.isNotEmpty) {
      return EmptyListPlaceholder(
        title: 'No more places left',
        subtitle:
            'Try searching in a different area or try using different filters',
        action: helperActions,
      );
    }

    if (_allLocations.isEmpty) {
      return EmptyListPlaceholder(
        title: 'No places found',
        subtitle:
            'Try searching in a different area or try using different filters',
        action: helperActions,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        fit: StackFit.expand,
        children: _cards(),
      ),
    );
  }

  List<Widget> _cards() {
    final List<Widget> cardWidgets = [];
    final width = MediaQuery.of(context).size.width;

    for (var i = 0; i < _locations.length; i++) {
      final item = _locations[i];
      if (i == _locations.length - 1) {
        cardWidgets.add(
          AnimatedCard(
            controller: _animatedCardController,
            dismissLeft: _dismissLeft,
            dismissRight: _dismissRight,
            width: width,
            child: LocationCard(
              isStoryView: true,
              item: item,
              storyController: _storyController,
              onViewDetails: _onViewDetails,
              userLocation: _userLocation,
            ),
          ),
        );
      } else {
        cardWidgets.add(
          LocationCard(
            isStoryView: false,
            item: item,
            storyController: _storyController,
            onViewDetails: _onViewDetails,
            userLocation: _userLocation,
          ),
        );
      }
    }

    return cardWidgets;
  }

  _onViewDetails() {
    _onViewLocationDetails(_currentLocation, event: LOCATION_INFO_SWIPING);
  }

  _onViewLocationDetails(
    SuggestedLocation location, {
    String event = LOCATION_INFO_SWIPING_LIST,
  }) {
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

  _onViewLocations() {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => LocationList(
        removeLocation: _onRemoveLocation,
        clearLocations: _onClearLocations,
        viewLocation: _onViewLocationDetails,
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

  _onSelectArea() async {
    final navigationService = locator<NavigationService>();
    final swipeFiltersProvider = locator<SwipeFiltersProvider>();

    final LatLngBounds selectedArea = await navigationService.push(
      MaterialPageRoute(
        builder: (context) => AreaSelection(),
      ),
    );

    if (selectedArea != null) {
      swipeFiltersProvider.setBounds(
        selectedArea.southwest,
        selectedArea.northeast,
        notify: true,
      );
    }
  }

  _onRemoveLocation(int index) {
    final swipeProvider = locator<SwipeProvider>();

    swipeProvider.removeLocationAt(index);
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

    if (_hasMore) {
      if (_currentLocationIndex + LOCATIONS_LOADED >= _allLocations.length) {
        _fetchMore();
      }
    }
  }

  _onSave() async {
    final theme = Theme.of(context);
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
              child: Text(
                'OK!',
                style: TextStyle(
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );

      return;
    }

    final navigationService = locator<NavigationService>();

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: FINISH_SWIPING);

    await navigationService.push(
      MaterialPageRoute(
        builder: (context) => SuggestedTrip(
          locations: locations,
        ),
      ),
    );
  }

  _onDismiss() {
    _animatedCardController.swipeLeft();
  }

  _onSelect() {
    _animatedCardController.swipeRight();
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
