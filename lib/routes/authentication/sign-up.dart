import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/auth.dart';
import 'package:mywonderbird/constants/error-codes.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/routes/authentication/components/screen-layout.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/types/confirm-account-arguments.dart';
import 'package:provider/provider.dart';

import 'confirm.dart';

class SignUp extends StatefulWidget {
  static const RELATIVE_PATH = 'sign-up';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<User>(context, listen: false);
    final authenticationService = locator<AuthenticationService>();

    authenticationService.afterSignIn(user);
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
          onPressed: _onSignUp,
          child: BodyText1.light('SIGN UP'),
          color: theme.accentColor,
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

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < MIN_PASSWORD_LENGTH) {
      return "Password must be at least $MIN_PASSWORD_LENGTH characters long";
    }

    return null;
  }

  _onSignUp() async {
    try {
      setState(() {
        _error = null;
      });

      if (_formKey.currentState.validate()) {
        final authenticationService = locator<AuthenticationService>();

        final email = _emailController.text;
        final password = _passwordController.text;

        await authenticationService.signUp(email, password);

        final user = await authenticationService.signIn(email, password);

        authenticationService.afterSignIn(user);
      }
    } on AuthenticationException catch (e) {
      switch (e.errorCode) {
        case USER_NOT_CONFIRMED:
          _navigateToConfirmation();
          break;
        case USERNAME_EXISTS:
          setState(() {
            _error = 'The email is already in use';
          });
          break;
        default:
          setState(() {
            _error = 'We were unable to sign you up';
          });
          break;
      }
    } catch (e) {
      setState(() {
        _error = 'We were unable to sign you up';
      });
    }
  }

  _navigateToConfirmation() {
    Navigator.of(context).pushNamed(
      Confirm.RELATIVE_PATH,
      arguments: ConfirmAccountArguments(
        email: _emailController.text,
        password: _passwordController.text,
        message:
            'A confirmation code has been sent to your email. Use it to confirm your account.',
      ),
    );
  }
}
