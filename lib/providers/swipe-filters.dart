import 'package:flutter/cupertino.dart';

class SwipeFiltersProvider with ChangeNotifier {
  List<String> _selectedTags = [];

  List<String> get selectedTags => _selectedTags;

  set selectedTags(List<String> selectedTags) {
    _selectedTags = selectedTags;
    notifyListeners();
  }

  clear() {
    _selectedTags.clear();
    notifyListeners();
  }
}
