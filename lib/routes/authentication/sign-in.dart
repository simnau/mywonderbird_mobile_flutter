import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:layout/components/auth-text-field.dart';
import 'package:layout/constants/error-codes.dart';
import 'package:layout/exceptions/authentication-exception.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/user.dart';
import 'package:layout/routes/authentication/components/screen-layout.dart';
import 'package:layout/routes/authentication/confirm.dart';
import 'package:layout/routes/home/main.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/types/confirm-account-arguments.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  static const RELATIVE_PATH = 'sign-in';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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
          onPressed: _onSignIn,
          child: Text('SIGN IN'),
          color: theme.accentColor,
          textColor: Colors.white,
        ),
        FlatButton(
          onPressed: _onSignIn,
          child: Text(
            'FORGOT DETAILS?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        RaisedButton(
          onPressed: _onSignIn,
          child: Text('SIGN IN WITH FACEBOOK'),
          color: Color(0xFF3B5798),
          textColor: Colors.white,
        ),
        RaisedButton(
          onPressed: _onSignIn,
          child: Text('SIGN IN WITH GOOGLE'),
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

  _onSignIn() async {
    try {
      setState(() {
        _error = null;
      });

      if (_formKey.currentState.validate()) {
        final user = await locator<AuthenticationService>().signIn(
          _emailController.text,
          _passwordController.text,
        );

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
            _error = 'Invalid password / email combination';
          });
          break;
      }
    }
  }

  _navigateToHome() async {
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
