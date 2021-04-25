import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/error-codes.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/authentication/components/screen-layout.dart';
import 'package:mywonderbird/routes/authentication/components/sign-in-form.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/util/snackbar.dart';

import 'forgot-details.dart';

class LinkEmailPassword extends StatefulWidget {
  final String email;

  const LinkEmailPassword({
    Key key,
    this.email,
  }) : super(key: key);

  @override
  _LinkEmailPasswordState createState() => _LinkEmailPasswordState();
}

class _LinkEmailPasswordState extends State<LinkEmailPassword> {
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
              email: widget.email,
              onForgotDetails: _onForgotDetails,
              onSubmit: ({email, password}) => _onSignIn(
                context: context,
                email: email,
                password: password,
              ),
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
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final navigationService = locator<NavigationService>();

      navigationService.pop(credential);
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

  _onForgotDetails({
    String email,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ForgotDetails(
          email: email,
        ),
      ),
    );
  }
}
