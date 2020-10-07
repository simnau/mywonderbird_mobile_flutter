import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/auth.dart';
import 'package:mywonderbird/constants/error-codes.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/types/sign-in-arguments.dart';

import 'components/screen-layout.dart';
import 'sign-in.dart';

class ResetPassword extends StatefulWidget {
  static const RELATIVE_PATH = 'reset-password';
  static const PATH = "/$RELATIVE_PATH";

  final String email;

  const ResetPassword({
    Key key,
    this.email,
  }) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error;
  String _message;

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
            )
          else if (_message != null)
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              color: Colors.green,
              child: BodyText1.light(_message),
            ),
          AuthTextField(
            controller: _emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            labelText: 'EMAIL',
          ),
          AuthTextField(
            controller: _codeController,
            validator: _validateCode,
            keyboardType: TextInputType.number,
            labelText: 'CONFIRMATION CODE',
          ),
          AuthTextField(
            controller: _passwordController,
            validator: _validatePassword,
            keyboardType: TextInputType.text,
            labelText: 'PASSWORD',
            obscureText: true,
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
          child: Text('RESET PASSWORD'),
          color: theme.accentColor,
          colorBrightness: Brightness.dark,
        ),
        FlatButton(
          onPressed: _onResendCode,
          child: BodyText1('RESEND CODE'),
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

  String _validateCode(value) {
    if (value.isEmpty) {
      return 'Code is required';
    }

    return null;
  }

  String _validatePassword(value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < MIN_PASSWORD_LENGTH) {
      return "Password must be at least $MIN_PASSWORD_LENGTH characters long";
    }

    return null;
  }

  _onResetPassword() async {
    try {
      setState(() {
        _error = null;
        _message = null;
      });

      if (_formKey.currentState.validate()) {
        final authenticationService = locator<AuthenticationService>();

        await authenticationService.resetPassword(
          _emailController.text,
          _codeController.text,
          _passwordController.text,
        );

        _navigateToSignIn();
      }
    } on AuthenticationException catch (e) {
      setState(() {
        switch (e.errorCode) {
          case CODE_MISMATCH:
            _error = 'The code is invalid';
            break;
          case EXPIRED_CODE:
            _error = 'The code has expired';
            break;
          case LIMIT_EXCEEDED:
            _error = 'You have exceeded the limit of tries. Try again later';
            break;
          default:
            _error = 'There was an error resetting the password';
            break;
        }
      });
    }
  }

  _onResendCode() async {
    try {
      setState(() {
        _error = null;
        _message = null;
      });

      String emailError = _validateEmail(_emailController.text);

      if (emailError == null) {
        final authenticationService = locator<AuthenticationService>();

        await authenticationService.sendPasswordResetCode(
          _emailController.text,
        );

        setState(() {
          _message = 'A confirmation code has been sent to your email.';
        });
      } else {
        setState(() {
          _error = emailError;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An unexpected error has occurred. Please try again later.';
      });
    }
  }

  _navigateToSignIn() {
    final navigator = Navigator.of(context);

    navigator.popUntil((route) => route.settings.name == SignIn.RELATIVE_PATH);
    navigator.pushReplacementNamed(
      SignIn.RELATIVE_PATH,
      arguments: SignInArguments(
        email: _emailController.text,
        message: 'You can now sign in with your new password',
      ),
    );
  }
}
