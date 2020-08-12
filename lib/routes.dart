import 'package:flutter/material.dart';
import 'package:layout/routes/pdf/main.dart';
import 'package:layout/routes/profile/main.dart';
import 'package:layout/routes/terms/main.dart';
import 'package:layout/types/pdf-arguments.dart';
import 'package:layout/types/share-screen-arguments.dart';
import 'package:layout/types/terms-arguments.dart';

import 'routes/authentication/main.dart';
import 'routes/authentication/select-auth-option.dart';
import 'routes/home/main.dart';
import 'routes/profile/main.dart';
import 'routes/select-destination/main.dart';
import 'routes/select-picture/main.dart';
import 'routes/settings/main.dart';
import 'routes/share-picture/main.dart';
import 'routes/splash/main.dart';

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
    case SelectPicture.PATH:
      return MaterialPageRoute(
        builder: (_) => SelectPicture(),
        settings: settings,
      );
    case SelectDestination.PATH:
      return MaterialPageRoute(
        builder: (_) => SelectDestination(),
        settings: settings,
      );
    case ShareScreen.PATH:
      final ShareScreenArguments arguments = settings.arguments;
      return MaterialPageRoute(
        builder: (_) => ShareScreen(
          selectedJourney: arguments?.selectedJourney,
        ),
        settings: settings,
      );
    case Profile.PATH:
      return MaterialPageRoute(
        builder: (_) => Profile(),
        settings: settings,
      );
    case Settings.PATH:
      return MaterialPageRoute(
        builder: (_) => Settings(),
        settings: settings,
      );
    case PdfPage.PATH:
      PdfArguments arguments = settings.arguments;

      return MaterialPageRoute(
        builder: (_) => PdfPage(
          url: arguments.url,
          title: arguments.title,
        ),
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
