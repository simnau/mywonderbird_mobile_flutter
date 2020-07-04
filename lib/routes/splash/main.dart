import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/routes/authentication/select-auth-option.dart';
import 'package:layout/routes/authentication/sign-in.dart';
import 'package:layout/routes/home.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/navigation.dart';

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
    final user = await locator<AuthenticationService>().checkAuth();
    final navigationService = locator<NavigationService>();
    navigationService.popUntil((route) => route.isFirst);
    if (user != null) {
      await navigationService.pushReplacementNamed(Home.PATH);
    } else {
      await navigationService.pushReplacementNamed(SelectAuthOption.PATH);
    }
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
