import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/services/saved-trip.dart';

class SavedTripsProvider with ChangeNotifier {
  bool _loading = true;
  List<Journey> _savedTrips = [];

  UnmodifiableListView<Journey> get savedTrips =>
      UnmodifiableListView(_savedTrips);
  bool get loading => _loading;

  Future<List<Journey>> loadUserSavedTrips() async {
    final savedTripService = locator<SavedTripService>();
    try {
      _loading = true;
      notifyListeners();

      final trips = await savedTripService.fetchAll();

      _savedTrips = trips;
      _loading = false;
      notifyListeners();

      return trips;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return [];
    }
  }

  deleteTrip(Journey trip) async {
    final savedTripService = locator<SavedTripService>();

    await savedTripService.deleteTrip(trip.id);
    _savedTrips.remove(trip);
    notifyListeners();
  }

  clearState() {
    _loading = true;
    _savedTrips = [];
  }
}
