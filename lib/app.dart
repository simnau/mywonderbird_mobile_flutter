import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/deep-links.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes.dart';
import 'package:mywonderbird/routes/authentication/select-auth-option.dart';
import 'package:mywonderbird/routes/onboarding/main.dart';
import 'package:mywonderbird/routes/splash/main.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/onboarding.dart';
import 'package:mywonderbird/sharing-intent.dart';
import 'package:mywonderbird/theme/style.dart';

class App extends StatefulWidget {
  final String initialRoute;

  const App({
    Key key,
    this.initialRoute,
  }) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  String initialRoute;

  @override
  void initState() {
    super.initState();
    initialRoute = widget.initialRoute ?? SplashScreen.PATH;
    _onStartup();
  }

  @override
  void dispose() {
    locator<DeepLinks>().dispose();
    locator<SharingIntent>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsObserver = locator<FirebaseAnalyticsObserver>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyWonderbird',
      initialRoute: initialRoute,
      navigatorKey: locator<NavigationService>().navigatorKey,
      theme: appTheme,
      onGenerateRoute: generateRoute,
      navigatorObservers: [
        analyticsObserver,
      ],
    );
  }

  _onStartup() async {
    final onboardingService = locator<OnboardingService>();
    final completedOnboarding =
        await onboardingService.hasCompletedOnboarding();

    if (!completedOnboarding) {
      final navigationService = locator<NavigationService>();

      await navigationService.pushReplacement(
        MaterialPageRoute(
          builder: (context) => Onboarding(
            callback: _onAfterOnboarding,
          ),
        ),
      );
    } else {
      await _onAfterOnboarding();
    }
  }

  _onAfterOnboarding() async {
    await _checkAuth();
    locator<DeepLinks>().setupDeepLinkListeners();
    locator<SharingIntent>().setupSharingIntentListeners();
  }

  Future _checkAuth() async {
    final authenticationService = locator<AuthenticationService>();
    final user = await authenticationService.checkAuth();

    if (user != null) {
      await authenticationService.onStartup(user);
    } else {
      setState(() {
        initialRoute = SelectAuthOption.PATH;
      });
    }
  }
}
