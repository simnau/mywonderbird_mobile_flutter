import 'package:flutter/material.dart';

import 'routes/home.dart';
import 'routes/profile.dart';
import 'routes/select-picture/home.dart';
import 'routes/select-picture/main.dart';
import 'routes/share-picture/main.dart';
import 'routes/share-picture/select-destination.dart';

final Map<String, WidgetBuilder> appRoutes = <String, WidgetBuilder>{
  Home.PATH: (context) => Home(),
  SelectPictureHome.PATH: (context) => SelectPictureRoot(),
  SelectDestination.PATH: (context) => SharePictureRoot(),
  Profile.PATH: (context) => Profile(),
};
