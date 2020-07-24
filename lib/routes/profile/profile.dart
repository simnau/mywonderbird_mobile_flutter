import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/routes/authentication/select-auth-option.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/navigation.dart';

class Profile extends StatefulWidget {
  static const RELATIVE_PATH = 'profile';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: _onBack,
        ),
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

  void _onBack() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop();
  }
}
