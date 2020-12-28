import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/types/reset-password-arguments.dart';

import 'components/screen-layout.dart';
import 'reset-password.dart';

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
  String _error;

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
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              color: Colors.red,
              child: BodyText1.light(_error),
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
        RaisedButton(
          onPressed: _onResetPassword,
          child: BodyText1.light('REMIND PASSWORD'),
          color: theme.accentColor,
        ),
        FlatButton(
          onPressed: _onHasCode,
          child: BodyText1('I HAVE A CODE'),
        ),
      ],
    );
  }

  String _validateEmail(value) {
    if (value.isEmpty) {
      return 'Email is required';
    } else if (!EmailValidator.validate(value)) {
      return 'Email address is invalid';
    }

    return null;
  }

  _onResetPassword() async {
    try {
      setState(() {
        _error = null;
      });

      if (_formKey.currentState.validate()) {
        final authenticationService = locator<AuthenticationService>();

        await authenticationService.sendPasswordResetCode(
          _emailController.text,
        );

        _navigateToResetPassword();
      }
    } catch (e) {
      setState(() {
        _error = 'An unexpected error has occurred. Please try again later.';
      });
    }
  }

  _onHasCode() {
    _navigateToResetPassword();
  }

  _navigateToResetPassword() {
    Navigator.of(context).pushNamed(
      ResetPassword.RELATIVE_PATH,
      arguments: ResetPasswordArguments(
        email: _emailController.text,
      ),
    );
  }
}
