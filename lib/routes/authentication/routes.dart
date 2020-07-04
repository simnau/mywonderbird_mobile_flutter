import 'package:flutter/material.dart';
import 'package:layout/routes/authentication/select-auth-option.dart';

import 'sign-in.dart';
import 'sign-up.dart';

MaterialPageRoute onAuthenticationGenerateRoute(settings) {
  var path = settings.name;

  var builder;
  switch (path) {
    case SelectAuthOption.RELATIVE_PATH:
      builder = (BuildContext context) => SelectAuthOption();
      break;
    case SignIn.RELATIVE_PATH:
      builder = (BuildContext context) => SignIn();
      break;
    case SignUp.RELATIVE_PATH:
      builder = (BuildContext context) => SignUp();
      break;
    default:
      builder = (BuildContext context) => SelectAuthOption();
      break;
  }

  return MaterialPageRoute(builder: builder, settings: settings);
}
