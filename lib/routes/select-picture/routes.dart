import 'package:flutter/material.dart';

import 'home.dart';

MaterialPageRoute onSelectPictureGenerateRoute(settings) {
  var path = settings.name;

  var builder;
  switch (path) {
    case SelectPictureHome.RELATIVE_PATH:
      builder = (BuildContext context) => SelectPictureHome();
      break;
    default:
      builder = (BuildContext context) => SelectPictureHome();
      break;
  }

  return MaterialPageRoute(builder: builder);
}
