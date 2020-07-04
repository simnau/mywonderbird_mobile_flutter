import 'dart:io';

import 'package:flutter/cupertino.dart';

class AuthenticationProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  void checkAuth() async {
    _isLoading = true;
    notifyListeners();

    sleep(Duration(seconds: 2));

    _isLoading = false;
    _isAuthenticated = true;
    // notifyListeners();
  }
}
