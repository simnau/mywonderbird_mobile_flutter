import 'package:flutter/cupertino.dart';
import 'package:mywonderbird/models/suggested-location.dart';

class SwipeProvider with ChangeNotifier {
  List<SuggestedLocation> _selectedLocations = [];

  List<SuggestedLocation> get selectedLocations => _selectedLocations;

  selectLocation(SuggestedLocation location) {
    _selectedLocations.add(location);
    notifyListeners();
  }

  removeLocation(int locationIndex) {
    _selectedLocations.removeAt(locationIndex);
    notifyListeners();
  }

  clearLocations() {
    _selectedLocations.clear();
    notifyListeners();
  }
}
