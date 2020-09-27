import 'package:flutter/material.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/authentication/components/screen-layout.dart';
import 'package:mywonderbird/services/authentication.dart';

class Confirm extends StatefulWidget {
  static const RELATIVE_PATH = 'confirm';
  static const PATH = "/$RELATIVE_PATH";

  final String email;
  final String password;
  final String message;

  const Confirm({
    Key key,
    @required this.email,
    @required this.password,
    this.message,
  }) : super(key: key);

  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  String _error;
  String _message;

  @override
  void initState() {
    super.initState();

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
          colorBrightness: Brightness.dark,
        ),
        FlatButton(
          onPressed: _sendCode,
          child: BodyText1('RESEND CODE'),
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
        _message = null;
      });

      if (_formKey.currentState.validate()) {
        await authenticationService.confirmAccount(
          widget.email,
          _codeController.text,
        );

        final user =
            await authenticationService.signIn(widget.email, widget.password);

        authenticationService.afterSignIn(user);
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
        _message = null;
      });

      await locator<AuthenticationService>().sendConfirmationCode(
        widget.email,
      );

      setState(() {
        _message = 'A confirmation code has been sent to your email.';
      });
    } catch (e) {
      setState(() {
        _error = 'There was an error sending the code';
      });
    }
  }
}
