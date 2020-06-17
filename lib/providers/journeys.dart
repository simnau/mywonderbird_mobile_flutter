import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:layout/models/journey.dart';
import 'package:layout/services/journeys.dart';

class JourneysProvider with ChangeNotifier {
  bool _loading = true;
  List<Journey> _journeys = [];

  UnmodifiableListView<Journey> get journeys => UnmodifiableListView(_journeys);
  bool get loading => _loading;

  Future<List<Journey>> loadUserJourneys() async {
    try {
      _loading = true;
      notifyListeners();

      final journeys = await JourneyService.allForUser();

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
    final createdJourney = await JourneyService.createJourney(journey);
    _journeys.insert(0, createdJourney);
    notifyListeners();

    return journey;
  }

  void clearState() {
    _loading = true;
    _journeys = [];
  }
}
