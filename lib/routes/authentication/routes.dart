import 'package:flutter/material.dart';
import 'package:layout/routes/authentication/forgot-details.dart';
import 'package:layout/routes/authentication/reset-password.dart';
import 'package:layout/routes/authentication/select-auth-option.dart';
import 'package:layout/types/confirm-account-arguments.dart';
import 'package:layout/types/forgot-details-arguments.dart';
import 'package:layout/types/reset-password-arguments.dart';
import 'package:layout/types/sign-in-arguments.dart';

import 'confirm.dart';
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
      SignInArguments arguments = settings.arguments;
      builder = (BuildContext context) => SignIn(
            email: arguments?.email,
            message: arguments?.message,
          );
      break;
    case SignUp.RELATIVE_PATH:
      builder = (BuildContext context) => SignUp();
      break;
    case Confirm.RELATIVE_PATH:
      ConfirmAccountArguments arguments = settings.arguments;
      builder = (BuildContext context) => Confirm(
            email: arguments?.email,
            password: arguments?.password,
            message: arguments?.message,
          );
      break;
    case ForgotDetails.RELATIVE_PATH:
      ForgotDetailsArguments arguments = settings.arguments;
      builder = (BuildContext context) => ForgotDetails(
            email: arguments?.email,
          );
      break;
    case ResetPassword.RELATIVE_PATH:
      ResetPasswordArguments arguments = settings.arguments;
      builder = (BuildContext context) => ResetPassword(
            email: arguments?.email,
          );
      break;
    default:
      builder = (BuildContext context) => SelectAuthOption();
      break;
  }

  return MaterialPageRoute(builder: builder, settings: settings);
}
