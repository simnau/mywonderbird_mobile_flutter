import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/routes/authentication/select-auth-option.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/navigation.dart';

class Settings extends StatelessWidget {
  static const RELATIVE_PATH = 'settings';
  static const PATH = "/$RELATIVE_PATH";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: RaisedButton(
          onPressed: _signOut,
          child: Text('Sign Out'),
        ),
      ),
    );
  }

  void _signOut() async {
    final user = await locator<AuthenticationService>().signOut();

    if (user == null) {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() async {
    final navigationService = locator<NavigationService>();
    navigationService.popUntil((route) => route.isFirst);
    navigationService.pushReplacementNamed(SelectAuthOption.PATH);
  }
}
