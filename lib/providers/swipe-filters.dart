import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SwipeFiltersProvider with ChangeNotifier {
  List<String> _selectedTags = [];
  LatLng _northEast;
  LatLng _southWest;

  List<String> get selectedTags => _selectedTags;
  LatLng get northEast => _northEast;
  LatLng get southWest => _southWest;

  set selectedTags(List<String> selectedTags) {
    _selectedTags = selectedTags;
    notifyListeners();
  }

  setBounds(LatLng southWest, LatLng northEast, {notify: true}) {
    _northEast = northEast;
    _southWest = southWest;

    if (notify) {
      notifyListeners();
    }
  }

  clear() {
    _selectedTags.clear();
    notifyListeners();
  }
}
