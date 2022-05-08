import 'dart:async';

import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/providers/sharing-intent.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/oauth.dart';
import 'package:mywonderbird/util/sentry.dart';
import 'package:uni_links/uni_links.dart';

class DeepLinks {
  StreamSubscription _intentDataStreamSubscription;

  setupDeepLinkListeners() async {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = getLinksStream().listen((String link) {
      Uri uri = Uri.parse(link);

      if (uri == null) {
        return;
      }

      _handleDeepLink(uri.host, uri.queryParameters['code']);
      // Parse the link and warn the user, if it is not correct
    }, onError: (err) {
      print(err);
    });

    try {
      Uri initialUri = await getInitialUri();

      if (initialUri == null) {
        return;
      }

      _handleDeepLink(initialUri.host, initialUri.queryParameters['code']);
      // Use the uri and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on FormatException catch (error, stackTrace) {
      await reportError(error, stackTrace);
    }
  }

  dispose() {
    _intentDataStreamSubscription.cancel();
  }

  _handleDeepLink(route, code) async {
    switch (route) {
      case "notifications":
        final sharingIntentProvider = locator<SharingIntentProvider>();
        return sharingIntentProvider.deepLink = "notifications";
      case "achievements":
        final sharingIntentProvider = locator<SharingIntentProvider>();
        return sharingIntentProvider.deepLink = "achievements";
    }

    try {
      final oauthService = locator<OAuthService>();
      final authenticationService = locator<AuthenticationService>();
      var user;
      switch (route) {
        case 'fblogin':
          user = await oauthService.fblogin(code);
          break;
        case 'glogin':
          user = await oauthService.glogin(code);
          break;
        default:
          break;
      }

      await authenticationService.afterSignIn(user);
    } on AuthenticationException catch (e) {
      // TODO show exceptions
      switch (e.errorCode) {
        default:
          break;
      }
    }
  }
}
