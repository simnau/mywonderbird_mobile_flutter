import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mywonderbird/exceptions/unauthorized-exception.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:mywonderbird/providers/oauth.dart';
import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/routes/splash/main.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/oauth.dart';
import 'package:mywonderbird/util/sentry.dart';
import 'package:provider/provider.dart';

import 'locator.dart';
import 'app.dart';

Future main({String env = 'dev'}) async {
  await DotEnv().load("env/.env-$env");
  setupLocator(env: env);

  var initialRoute;

  try {
    await _initOAuthUrl();
  } on UnauthorizedException {
    initialRoute = SplashScreen.PATH;
  }

  runZonedGuarded<Future<void>>(() async {
    runApp(_app(initialRoute));
  }, (Object error, StackTrace stackTrace) {
    reportError(error, stackTrace);
  });
}

Widget _app(initialRoute) {
  final oauthProvider = locator<OAuthProvider>();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<JourneysProvider>(
        create: (_) => locator<JourneysProvider>(),
      ),
      ChangeNotifierProvider<SharePictureProvider>(
        create: (_) => locator<SharePictureProvider>(),
      ),
      StreamProvider<User>(
        initialData: null,
        create: (context) => locator<AuthenticationService>().userStream,
      ),
      ChangeNotifierProvider<OAuthProvider>(
        create: (_) => oauthProvider,
      )
    ],
    child: App(initialRoute: initialRoute),
  );
}

_initOAuthUrl() async {
  final oauthProvider = locator<OAuthProvider>();
  final authorizeUrl = await locator<OAuthService>().getAuthorizationUrl();
  oauthProvider.authorizeUrl = authorizeUrl;
}
