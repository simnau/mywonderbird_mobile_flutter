import 'package:flutter/material.dart';
import 'package:layout/providers/journeys.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/routes.dart';
import 'package:layout/routes/home.dart';
import 'package:layout/theme/style.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<JourneysProvider>(
          create: (_) => JourneysProvider(),
        ),
        ChangeNotifierProvider<SharePictureProvider>(
          create: (_) => SharePictureProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyWonderbird',
        initialRoute: Home.PATH,
        routes: appRoutes,
        theme: appTheme,
      ),
    );
  }
}
