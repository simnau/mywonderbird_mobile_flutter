import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:layout/models/user.dart';
import 'package:layout/providers/journeys.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/services/authentication.dart';
import 'package:provider/provider.dart';

import 'locator.dart';
import 'app.dart';

Future main() async {
  setupLocator();
  await DotEnv().load('.env');
  runApp(
    MultiProvider(
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
      ],
      child: App(),
    ),
  );
}
