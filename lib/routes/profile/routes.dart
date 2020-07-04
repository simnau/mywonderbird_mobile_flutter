import 'package:flutter/material.dart';

import 'profile.dart';

MaterialPageRoute onProfileGenerateRoute(settings) {
  var path = settings.name;

  var builder;
  switch (path) {
    case Profile.RELATIVE_PATH:
      builder = (BuildContext context) => Profile();
      break;
    default:
      builder = (BuildContext context) => Profile();
      break;
  }

  return MaterialPageRoute(builder: builder);
}
