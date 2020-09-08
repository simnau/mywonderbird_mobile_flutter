import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/constants/error-codes.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/routes/authentication/components/screen-layout.dart';
import 'package:mywonderbird/routes/authentication/confirm.dart';
import 'package:mywonderbird/routes/authentication/forgot-details.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/types/confirm-account-arguments.dart';
import 'package:mywonderbird/types/forgot-details-arguments.dart';
import 'package:provider/provider.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error;
  String _message;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<User>(context, listen: false);
    final authenticationService = locator<AuthenticationService>();

    authenticationService.afterSignIn(user);

    if (widget.email != null) {
      _emailController.text = widget.email;
    }

    if (widget.message != null) {
      _message = widget.message;
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
              child: Text(
                _error,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            )
          else if (_message != null)
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              color: Colors.green,
              child: Text(
                _message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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
          onPressed: _onSignIn,
          child: Text('SIGN IN'),
          color: theme.accentColor,
          colorBrightness: Brightness.dark,
        ),
        FlatButton(
          onPressed: _onForgotDetails,
          child: Text(
            'FORGOT DETAILS?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
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

  String _validatePassword(value) {
    if (value.isEmpty) {
      return 'Password is required';
    }

    return null;
  }

  _onSignIn() async {
    try {
      setState(() {
        _error = null;
        _message = null;
      });

      if (_formKey.currentState.validate()) {
        final authenticationService = locator<AuthenticationService>();

        final user = await authenticationService.signIn(
          _emailController.text,
          _passwordController.text,
        );

        authenticationService.afterSignIn(user);
      }
    } on AuthenticationException catch (e) {
      switch (e.errorCode) {
        case USER_NOT_CONFIRMED:
          _navigateToConfirmation();
          break;
        default:
          setState(() {
            _error = 'Invalid password / email combination';
          });
          break;
      }
    }
  }

  _onForgotDetails() {
    _navigateToForgotDetails();
  }

  _navigateToConfirmation() {
    Navigator.of(context).pushNamed(
      Confirm.RELATIVE_PATH,
      arguments: ConfirmAccountArguments(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  _navigateToForgotDetails() {
    Navigator.of(context).pushNamed(
      ForgotDetails.RELATIVE_PATH,
      arguments: ForgotDetailsArguments(
        email: _emailController.text,
      ),
    );
  }
}
