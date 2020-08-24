import 'package:flutter/material.dart';
import 'package:mywonderbird/deep-links.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes.dart';
import 'package:mywonderbird/routes/splash/main.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/sharing-intent.dart';
import 'package:mywonderbird/theme/style.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    _checkAuth().then((_) {
      locator<DeepLinks>().setupDeepLinkListeners();
      locator<SharingIntent>().setupSharingIntentListeners();
    });
  }

  @override
  void dispose() {
    locator<DeepLinks>().dispose();
    locator<SharingIntent>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyWonderbird',
      initialRoute: SplashScreen.PATH,
      navigatorKey: locator<NavigationService>().navigatorKey,
      theme: appTheme,
      onGenerateRoute: generateRoute,
    );
  }

  Future _checkAuth() async {
    final authenticationService = locator<AuthenticationService>();
    final user = await authenticationService.checkAuth();
    await authenticationService.onStartup(user);
  }
}
