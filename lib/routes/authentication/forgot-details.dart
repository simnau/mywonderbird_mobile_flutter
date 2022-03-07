import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/util/snackbar.dart';

import 'components/screen-layout.dart';

class ForgotDetails extends StatefulWidget {
  static const RELATIVE_PATH = 'forgot-details';
  static const PATH = "/$RELATIVE_PATH";

  final String email;

  const ForgotDetails({
    Key key,
    this.email,
  }) : super(key: key);

  @override
  _ForgotDetailsState createState() => _ForgotDetailsState();
}

class _ForgotDetailsState extends State<ForgotDetails> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: ScreenLayout(
        child: _form(),
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 120,
                height: 120,
                child: Image(
                  image: AssetImage('images/logo.png'),
                ),
              ),
            ),
          ),
          AuthTextField(
            controller: _emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            labelText: 'EMAIL',
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
          ),
          _actions(),
        ],
      ),
    );
  }

  Widget _actions() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => _onResetPassword(context),
              child: BodyText1.light('REMIND PASSWORD'),
              style: ElevatedButton.styleFrom(
                primary: theme.accentColor,
              ),
            );
          },
        ),
      ],
    );
  }

  String _validateEmail(value) {
    if (value.trim().isEmpty) {
      return 'Email is required';
    } else if (!EmailValidator.validate(value.trim())) {
      return 'Email address is invalid';
    }

    return null;
  }

  _onResetPassword(BuildContext context) async {
    try {
      if (_formKey.currentState.validate()) {
        final authenticationService = locator<AuthenticationService>();

        await authenticationService.sendPasswordResetEmail(
          _emailController.text.trim(),
        );

        final snackBar = createSuccessSnackbar(
          text:
              'An email with a link to reset your password has been sent to you',
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
