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

  JourneysProvider() {
    loadUserJourneys();
  }

  Future<List<Journey>> loadUserJourneys() async {
    _loading = true;
    notifyListeners();

    final journeys = await JourneyService.allForUser();

    _journeys = journeys;
    _loading = false;
    notifyListeners();

    return journeys;
  }

  Future<Journey> addJourney(Journey journey) async {
    final createdJourney = await JourneyService.createJourney(journey);
    _journeys.insert(0, createdJourney);
    notifyListeners();

    return journey;
  }
}
