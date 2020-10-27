import 'package:flutter/cupertino.dart';

class QuestionnaireProvider with ChangeNotifier {
  Map<String, dynamic> _qValues;

  Map<String, dynamic> get qValues => _qValues;

  set qValues(Map<String, dynamic> qValues) {
    _qValues = qValues;
    notifyListeners();
  }
}
