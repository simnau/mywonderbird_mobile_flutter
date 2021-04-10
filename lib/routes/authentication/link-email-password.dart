import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/error-codes.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/authentication/components/screen-layout.dart';
import 'package:mywonderbird/services/navigation.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
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
            enabled: widget.email == null,
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
        ElevatedButton(
          onPressed: _onSignIn,
          child: BodyText1.light('SIGN IN'),
          style: ElevatedButton.styleFrom(
            primary: theme.accentColor,
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
        final credential = EmailAuthProvider.credential(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final navigationService = locator<NavigationService>();

        navigationService.pop(credential);
      }
    } on AuthenticationException catch (e) {
      switch (e.errorCode) {
        case INVALID_CREDENTIALS:
          setState(() {
            _error = e.cause;
          });
          break;
        case TOO_MANY_ATTEMPTS:
          setState(() {
            _error = e.cause;
          });
          break;
        default:
          setState(() {
            _error = 'There was an error signing you in';
          });
          break;
      }
    }
  }
}
