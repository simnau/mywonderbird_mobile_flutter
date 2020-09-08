import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/services/suggestion.dart';

class JourneyProvider with ChangeNotifier {
  FullJourney _journey;
  bool _loading = true;

  FullJourney get journey => _journey;
  bool get loading => _loading;

  Future<FullJourney> suggestJourney(String bookmarkGroupId) async {
    final suggestionService = locator<SuggestionService>();

    try {
      _loading = true;
      notifyListeners();

      final journey = await suggestionService.suggestJourney(bookmarkGroupId);

      _journey = journey;
      _loading = false;
      notifyListeners();

      return journey;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  clearState() {
    _loading = true;
    _journey = null;
  }
}
