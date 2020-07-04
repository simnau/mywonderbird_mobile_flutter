import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:layout/exceptions/authentication-exception.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/user.dart';
import 'package:layout/routes/home/main.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/navigation.dart';
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
      body: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/mywonderbird-travel.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 64.0,
                        bottom: 32.0,
                        left: 32.0,
                        right: 32.0,
                      ),
                      child: _form(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _form() {
    final theme = Theme.of(context);
    final textFieldTheme = theme.copyWith(
      hintColor: Colors.black,
      primaryColor: theme.primaryColorDark,
    );

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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.red[600],
              ),
              child: Text(
                _error,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          Theme(
            data: textFieldTheme,
            child: TextFormField(
              controller: _emailController,
              validator: _validateEmail,
              decoration: InputDecoration(
                labelText: 'EMAIL',
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                errorStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
          ),
          Theme(
            data: textFieldTheme,
            child: TextFormField(
              controller: _passwordController,
              validator: _validatePassword,
              decoration: InputDecoration(
                labelText: 'PASSWORD',
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                errorStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              keyboardType: TextInputType.text,
              obscureText: true,
            ),
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

  void _onSignIn() async {
    try {
      setState(() {
        _error = null;
      });

      if (_formKey.currentState.validate()) {
        print(_formKey.currentState);
        final user = await locator<AuthenticationService>().signIn(
          _emailController.text,
          _passwordController.text,
        );

        // if (user != null) {
        // _navigateToHome();
        // }
      }
    } on AuthenticationException {
      setState(() {
        _error = 'Invalid password / username combination';
      });
    }
  }

  void _navigateToHome() async {
    await locator<NavigationService>().pushReplacementNamed(HomePage.PATH);
  }
}
