import 'package:flutter/material.dart';
import 'package:mywonderbird/routes/bookmarks/main.dart';
import 'package:mywonderbird/routes/notifications/main.dart';
import 'package:mywonderbird/routes/terms/main.dart';
import 'package:mywonderbird/types/terms-arguments.dart';

import 'routes/authentication/main.dart';
import 'routes/authentication/select-auth-option.dart';
import 'routes/home/main.dart';
import 'routes/settings/main.dart';
import 'routes/splash/main.dart';
import 'routes/functionality-coming-soon/main.dart';
import 'routes/feedback/form/main.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomePage.PATH:
      return MaterialPageRoute(
        builder: (_) => HomePage(),
        settings: settings,
      );
    case SelectAuthOption.PATH:
      return MaterialPageRoute(
        builder: (_) => AuthenticationHome(),
        settings: settings,
      );
    case TermsPage.PATH:
      TermsArguments arguments = settings.arguments;

      return MaterialPageRoute(
        builder: (_) => TermsPage(
          isUpdate: arguments.isUpdate,
        ),
        settings: settings,
      );
    case SplashScreen.PATH:
      return MaterialPageRoute(
        builder: (_) => SplashScreen(),
        settings: settings,
      );
    case Settings.PATH:
      return MaterialPageRoute(
        builder: (_) => Settings(),
        settings: settings,
      );
    case Bookmarks.PATH:
      return MaterialPageRoute(
        builder: (_) => Bookmarks(),
        settings: settings,
      );
    case Notifications.PATH:
      return MaterialPageRoute(
        builder: (_) => Notifications(),
        settings: settings,
      );
    case ComingSoonScreen.PATH:
      return MaterialPageRoute(
        builder: (_) => ComingSoonScreen(),
        settings: settings,
      );
    case FeedbackForm.PATH:
      return MaterialPageRoute(
        builder: (_) => FeedbackForm(),
        settings: settings,
      );
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
  }
}
