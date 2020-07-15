import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:layout/components/auth-text-field.dart';
import 'package:layout/constants/error-codes.dart';
import 'package:layout/constants/oauth.dart';
import 'package:layout/exceptions/authentication-exception.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/user.dart';
import 'package:layout/providers/oauth.dart';
import 'package:layout/routes/authentication/components/screen-layout.dart';
import 'package:layout/routes/home/main.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/types/confirm-account-arguments.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

    if (user != null) {
      _navigateToHome();
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
          child: Text('SIGN UP'),
          color: theme.accentColor,
          textColor: Colors.white,
        ),
        RaisedButton(
          onPressed: _onFacebookSignUp,
          child: Text('SIGN UP WITH FACEBOOK'),
          color: Color(0xFF3B5798),
          textColor: Colors.white,
        ),
        RaisedButton(
          onPressed: _onGoogleSignUp,
          child: Text('SIGN UP WITH GOOGLE'),
          color: Colors.white,
          textColor: Color(0xFF757575),
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

  _onSignUp() async {
    final authenticationService = locator<AuthenticationService>();

    try {
      setState(() {
        _error = null;
      });

      if (_formKey.currentState.validate()) {
        final email = _emailController.text;
        final password = _emailController.text;
        await authenticationService.signUp(
          _emailController.text,
          _passwordController.text,
        );
        final user = await authenticationService.signIn(email, password);

        if (user != null) {
          _navigateToHome();
        }
      }
    } on AuthenticationException catch (e) {
      switch (e.errorCode) {
        case USER_NOT_CONFIRMED:
          _navigateToConfirmation();
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

  _onFacebookSignUp() async {
    final authorizeUrl = locator<OAuthProvider>().authorizeUrl;
    final redirectUrl =
        "$authorizeUrl&redirect_uri=$FB_SIGN_UP_REDIRECT_URL&identity_provider=Facebook";

    if (await canLaunch(redirectUrl)) {
      await launch(redirectUrl);
    } else {
      throw 'Could not launch $redirectUrl';
    }
  }

  _onGoogleSignUp() async {
    final authorizeUrl = locator<OAuthProvider>().authorizeUrl;
    final redirectUrl =
        "$authorizeUrl&redirect_uri=$GOOGLE_SIGN_UP_REDIRECT_URL&identity_provider=Google";

    if (await canLaunch(redirectUrl)) {
      await launch(redirectUrl);
    } else {
      throw 'Could not launch $redirectUrl';
    }
  }

  void _navigateToHome() async {
    await locator<NavigationService>().pushReplacementNamed(HomePage.PATH);
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
}
