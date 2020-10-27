import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mywonderbird/components/small-icon-button.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/providers/questionnaire.dart';
import 'package:mywonderbird/routes/location-details/main.dart';
import 'package:mywonderbird/routes/suggested-trip/main.dart';
import 'package:mywonderbird/routes/swipe-locations/components/selected-locations.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/suggestion.dart';
import 'package:provider/provider.dart';

import 'components/animated-card.dart';

const LOCATIONS_LOADED = 3;

class SwipeLocations extends StatefulWidget {
  final List<SuggestedLocation> initialLocations;

  const SwipeLocations({
    Key key,
    @required this.initialLocations,
  }) : super(key: key);

  @override
  _SwipeLocationsState createState() => _SwipeLocationsState();
}

class _SwipeLocationsState extends State<SwipeLocations> {
  final _animatedCardController = AnimatedCardController();
  List<SuggestedLocation> _locations;
  List<SuggestedLocation> _selectedLocations = [];
  int _currentLocationIndex = 0;

  SuggestedLocation get _currentLocation =>
      _locations.isNotEmpty ? _locations[_locations.length - 1] : null;

  List<SuggestedLocation> get _locationSublist {
    return widget.initialLocations
        .sublist(
          _currentLocationIndex,
          min(
            _currentLocationIndex + LOCATIONS_LOADED,
            widget.initialLocations.length,
          ),
        )
        .reversed
        .toList();
  }

  @override
  void initState() {
    super.initState();

    _locations = _locationSublist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    final questionnaireProvider = Provider.of<QuestionnaireProvider>(context);

    final duration = (questionnaireProvider.qValues['duration']) as int;
    final locationCount =
        (questionnaireProvider.qValues['locationCount']) as int;

    if (_selectedLocations.length == duration * locationCount) {
      _next();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectedLocations(selectedLocations: _selectedLocations),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ..._cards(),
            ],
          ),
        ),
        _actions(),
      ],
    );
  }

  List<Widget> _cards() {
    final cards = List<Widget>();
    final width = MediaQuery.of(context).size.width;

    for (var i = 0; i < _locations.length; i++) {
      if (i == _locations.length - 1) {
        cards.add(
          AnimatedCard(
            controller: _animatedCardController,
            dismissLeft: _dismissLeft,
            dismissRight: _dismissRight,
            width: width,
            child: _card(context, i),
          ),
        );
      } else {
        cards.add(_card(context, i));
      }
    }

    return cards;
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
            // Align(
            //   alignment: Alignment.center,
            //   child: FloatingActionButton(
            //     onPressed: _onBookmark,
            //     foregroundColor: Colors.black87,
            //     backgroundColor: Colors.white,
            //     heroTag: null,
            //     mini: true,
            //     child: GradientIcon(
            //       Icons.turned_in,
            //       24,
            //       LinearGradient(
            //         begin: Alignment.topLeft,
            //         end: Alignment.bottomRight,
            //         colors: [Colors.blue[100], Colors.blue],
            //       ),
            //     ),
            //   ),
            // ),
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

  Widget _card(BuildContext context, int index) {
    final item = _locations[index];

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.images.isNotEmpty && item.images.first.url != null)
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
  }

  _dismissLeft() {
    setState(() {
      _currentLocationIndex += 1;
      _locations = _locationSublist;
    });

    if (_currentLocationIndex >= widget.initialLocations.length) {
      _next();
    }
  }

  _dismissRight() {
    _selectedLocations.add(_currentLocation);
    setState(() {
      _currentLocationIndex += 1;
      _locations = _locationSublist;
    });

    if (_currentLocationIndex >= widget.initialLocations.length) {
      _next();
    }
  }

  _next() async {
    final navigationService = locator<NavigationService>();
    final suggestionService = locator<SuggestionService>();
    final locationIds =
        _selectedLocations.map((location) => location.id).toList();
    final suggestedJourney =
        await suggestionService.suggestJourneyFromLocations(locationIds);

    await navigationService.push(
      MaterialPageRoute(
        builder: (context) => SuggestedTrip(
          suggestedJourney: suggestedJourney,
        ),
      ),
    );

    _onReset();
  }

  _onBack() {
    final navigationService = locator<NavigationService>();
    navigationService.pop();
  }

  _onDismiss() {
    _animatedCardController.swipeLeft();
  }

  _onSelect() {
    _animatedCardController.swipeRight();
  }

  _onReset() {
    setState(() {
      _currentLocationIndex = 0;
      _locations = _locationSublist;
      _selectedLocations = [];
    });
  }
}
