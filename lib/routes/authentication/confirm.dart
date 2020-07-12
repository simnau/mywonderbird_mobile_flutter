import 'package:flutter/material.dart';
import 'package:layout/components/auth-text-field.dart';
import 'package:layout/exceptions/authentication-exception.dart';
import 'package:layout/locator.dart';
import 'package:layout/routes/authentication/components/screen-layout.dart';
import 'package:layout/routes/home/main.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/navigation.dart';

class Confirm extends StatefulWidget {
  static const RELATIVE_PATH = 'confirm';
  static const PATH = "/$RELATIVE_PATH";

  final String email;
  final String password;

  const Confirm({
    Key key,
    @required this.email,
    @required this.password,
  }) : super(key: key);

  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  String _error;

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
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Image(
                image: AssetImage('images/logo.png'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                'PLEASE CONFIRM YOUR ACCOUNT',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
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
            controller: _codeController,
            validator: _validateCode,
            keyboardType: TextInputType.number,
            labelText: 'CONFIRMATION CODE',
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
          onPressed: _onConfirm,
          child: Text('CONFIRM ACCOUNT'),
          color: theme.accentColor,
          textColor: Colors.white,
        ),
        RaisedButton(
          onPressed: _sendCode,
          color: Colors.grey,
          textColor: Colors.white,
          child: Text(_codeSent ? 'RE-SEND CODE' : 'SEND CODE'),
        ),
      ],
    );
  }

  String _validateCode(value) {
    if (value.isEmpty) {
      return 'Code is required';
    }

    return null;
  }

  _onConfirm() async {
    final authenticationService = locator<AuthenticationService>();
    try {
      setState(() {
        _error = null;
      });

      if (_formKey.currentState.validate()) {
        await authenticationService.confirmAccount(
          widget.email,
          _codeController.text,
        );

        final user =
            await authenticationService.signIn(widget.email, widget.password);

        if (user != null) {
          _navigateToHome();
        }
      }
    } on AuthenticationException {
      setState(() {
        _error = 'Invalid code';
      });
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred. Try again later';
      });
    }
  }

  _sendCode() async {
    try {
      setState(() {
        _error = null;
      });

      await locator<AuthenticationService>().sendConfirmationCode(
        widget.email,
      );

      setState(() {
        _codeSent = true;
      });
    } catch (e) {
      setState(() {
        _error = 'There was an error sending the code';
      });
    }
  }

  _navigateToHome() {
    final navigationService = locator<NavigationService>();
    navigationService.popUntil((route) => route.isFirst);
    navigationService.pushReplacementNamed(HomePage.PATH);
  }
}
