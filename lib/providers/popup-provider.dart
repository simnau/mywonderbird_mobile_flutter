import 'package:flutter/material.dart';

class PopupProvider with ChangeNotifier {
  Map<String, dynamic> _popup;

  Map<String, dynamic> get popup {
    return _popup;
  }

  set popup(Map<String, dynamic> popupData) {
    _popup = popupData;
    notifyListeners();
  }
}
