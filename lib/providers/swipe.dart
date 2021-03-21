import 'package:flutter/cupertino.dart';
import 'package:mywonderbird/models/suggested-location.dart';

class SwipeProvider with ChangeNotifier {
  List<SuggestedLocation> _selectedLocations = [];

  List<SuggestedLocation> get selectedLocations => _selectedLocations;

  selectLocation(SuggestedLocation location) {
    _selectedLocations.add(location);
    notifyListeners();
  }

  removeLocationAt(int locationIndex) {
    _selectedLocations.removeAt(locationIndex);
    notifyListeners();
  }

  removeLocation(SuggestedLocation locationToRemove) {
    final index = _selectedLocations
        .indexWhere((location) => locationToRemove.id == location.id);

    if (index >= 0) {
      removeLocationAt(index);
    }
  }

  clearLocations() {
    _selectedLocations.clear();
    notifyListeners();
  }
}
