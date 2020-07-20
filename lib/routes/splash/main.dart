import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/services/authentication.dart';

class SplashScreen extends StatefulWidget {
  static const RELATIVE_PATH = 'splash';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final authenticationService = locator<AuthenticationService>();
    final user = await authenticationService.checkAuth();
    authenticationService.onStartup(user);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 10,
          ),
        ),
      ),
    );
  }
}
