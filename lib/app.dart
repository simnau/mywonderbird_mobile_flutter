import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/routes.dart';
import 'package:layout/routes/splash/main.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/sharing-intent.dart';
import 'package:layout/theme/style.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    locator<SharingIntent>().setupSharingIntentListeners();
  }

  @override
  void dispose() {
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
}
