import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:layout/models/user.dart';
import 'package:layout/providers/journeys.dart';
import 'package:layout/providers/oauth.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/oauth.dart';
import 'package:layout/util/sentry.dart';
import 'package:provider/provider.dart';

import 'locator.dart';
import 'app.dart';

Future main() async {
  await DotEnv().load('.env');
  setupLocator();

  final oauthProvider = locator<OAuthProvider>();
  final authorizeUrl = await locator<OAuthService>().getAuthorizationUrl();
  oauthProvider.authorizeUrl = authorizeUrl;

  runZonedGuarded<Future<void>>(() async {
    runApp(_app());
  }, (Object error, StackTrace stackTrace) {
    reportError(error, stackTrace);
  });
}

Widget _app() {
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
    child: App(),
  );
}
