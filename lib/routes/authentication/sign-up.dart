import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/user.dart';
import 'package:layout/routes/home/main.dart';
import 'package:layout/services/navigation.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  static const RELATIVE_PATH = 'sign-up';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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

    return ClipRect(
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
          Theme(
            data: textFieldTheme,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'EMAIL',
                labelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
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
            child: TextField(
              decoration: InputDecoration(
                labelText: 'PASSWORD',
                labelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              style: TextStyle(
                fontSize: 20,
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
          RaisedButton(
            onPressed: _onSignUp,
            child: Text('SIGN UP'),
            color: theme.accentColor,
            textColor: Colors.white,
          ),
          RaisedButton(
            onPressed: _onSignUp,
            child: Text('SIGN UP WITH FACEBOOK'),
            color: Color(0xFF3B5798),
            textColor: Colors.white,
          ),
          RaisedButton(
            onPressed: _onSignUp,
            child: Text('SIGN UP WITH GOOGLE'),
            color: Colors.white,
            textColor: Color(0xFF757575),
          ),
        ],
      ),
    );
  }

  void _onSignUp() {
    print('Sign Up');
  }

  void _navigateToHome() async {
    await locator<NavigationService>().pushReplacementNamed(HomePage.PATH);
  }
}
