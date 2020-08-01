import 'dart:async';

import 'package:layout/exceptions/authentication-exception.dart';
import 'package:layout/locator.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/oauth.dart';
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
    } on FormatException catch (e) {
      print(e);
    }
  }

  dispose() {
    _intentDataStreamSubscription.cancel();
  }

  _handleDeepLink(route, code) async {
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

      authenticationService.afterSignIn(user);
    } on AuthenticationException catch (e) {
      // TODO show exceptions
      switch (e.errorCode) {
        default:
          break;
      }
    }
  }
}
