import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/services/journeys.dart';

class JourneysProvider with ChangeNotifier {
  bool _loading = true;
  List<Journey> _journeys = [];

  UnmodifiableListView<Journey> get journeys => UnmodifiableListView(_journeys);
  bool get loading => _loading;

  Future<List<Journey>> loadUserJourneys() async {
    final journeyService = locator<JourneyService>();
    try {
      _loading = true;
      notifyListeners();

      final journeys = await journeyService.allForUser();

      _journeys = journeys;
      _loading = false;
      notifyListeners();

      return journeys;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return [];
    }
  }

  Future<Journey> addJourney(Journey journey) async {
    final journeyService = locator<JourneyService>();
    final createdJourney = await journeyService.createJourney(journey);
    _journeys.insert(0, createdJourney);
    notifyListeners();

    return createdJourney;
  }

  clearState() {
    _loading = true;
    _journeys = [];
  }
}
