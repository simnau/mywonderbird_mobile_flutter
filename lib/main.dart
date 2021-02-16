import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mywonderbird/exceptions/unauthorized-exception.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:mywonderbird/providers/oauth.dart';
import 'package:mywonderbird/providers/questionnaire.dart';
import 'package:mywonderbird/providers/saved-trips.dart';
import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/providers/swipe-filters.dart';
import 'package:mywonderbird/providers/swipe.dart';
import 'package:mywonderbird/providers/tags.dart';
import 'package:mywonderbird/routes/splash/main.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/oauth.dart';
import 'package:mywonderbird/util/sentry.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart' as sentry;

import 'locator.dart';
import 'app.dart';

Future main({String env = 'dev'}) async {
  await DotEnv().load("env/.env-$env");
  setupLocator(env: env);

  var initialRoute;

  try {
    await _initOAuthUrl();
    await _initTags();
  } on UnauthorizedException {
    initialRoute = SplashScreen.PATH;
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runZonedGuarded<Future<void>>(() async {
    final sentryDSN = DotEnv().env['SENTRY_DSN'];

    if (env == 'prod') {
      await sentry.Sentry.init(
        (options) {
          options.dsn = sentryDSN;
        },
      );
    }

    runApp(_app(initialRoute));
  }, (Object error, StackTrace stackTrace) {
    reportError(error, stackTrace);
  });
}

Widget _app(initialRoute) {
  final oauthProvider = locator<OAuthProvider>();
  final tagsProvider = locator<TagsProvider>();
  final questionnaireProvider = locator<QuestionnaireProvider>();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<JourneysProvider>(
        create: (_) => locator<JourneysProvider>(),
      ),
      ChangeNotifierProvider<SavedTripsProvider>(
        create: (_) => locator<SavedTripsProvider>(),
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
      ),
      ChangeNotifierProvider<TagsProvider>(
        create: (_) => tagsProvider,
      ),
      ChangeNotifierProvider<QuestionnaireProvider>(
        create: (_) => questionnaireProvider,
      ),
      ChangeNotifierProvider<SwipeFiltersProvider>(
        create: (_) => locator<SwipeFiltersProvider>(),
      ),
      ChangeNotifierProvider<SwipeProvider>(
        create: (_) => locator<SwipeProvider>(),
      ),
    ],
    child: App(initialRoute: initialRoute),
  );
}

_initOAuthUrl() async {
  final oauthProvider = locator<OAuthProvider>();
  final authorizeUrl = await locator<OAuthService>().getAuthorizationUrl();
  oauthProvider.authorizeUrl = authorizeUrl;
}

_initTags() async {
  final tagsProvider = locator<TagsProvider>();
  await tagsProvider.loadTags();
}
