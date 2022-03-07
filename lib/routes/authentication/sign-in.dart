import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/error-codes.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/authentication/components/screen-layout.dart';
import 'package:mywonderbird/routes/authentication/forgot-details.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/types/forgot-details-arguments.dart';
import 'package:mywonderbird/util/snackbar.dart';

import 'components/sign-in-form.dart';

class SignIn extends StatefulWidget {
  static const RELATIVE_PATH = 'sign-in';
  static const PATH = "/$RELATIVE_PATH";

  final String email;
  final String message;

  const SignIn({
    Key key,
    this.email,
    this.message,
  }) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: ScreenLayout(
        child: Builder(
          builder: (context) {
            return SignInForm(
              onForgotDetails: _navigateToForgotDetails,
              onSubmit: ({email, password}) => _onSignIn(
                context: context,
                email: email.trim(),
                password: password,
              ),
              email: widget.email,
            );
          },
        ),
      ),
    );
  }

  _onSignIn({
    BuildContext context,
    String email,
    String password,
  }) async {
    try {
      final authenticationService = locator<AuthenticationService>();

      await authenticationService.signIn(
        email,
        password,
      );
    } on AuthenticationException catch (e) {
      var error;
      switch (e.errorCode) {
        case INVALID_CREDENTIALS:
        case TOO_MANY_ATTEMPTS:
          error = e.cause;
          break;
        default:
          error = 'There was an error signing you in';
          break;
      }

      final snackBar = createErrorSnackbar(text: error);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _navigateToForgotDetails({
    String email,
  }) {
    Navigator.of(context).pushNamed(
      ForgotDetails.RELATIVE_PATH,
      arguments: ForgotDetailsArguments(
        email: email,
      ),
    );
  }
}
