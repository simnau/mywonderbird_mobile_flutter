import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';

class SignInForm extends StatefulWidget {
  final String email;
  final Function({
    String email,
  }) onForgotDetails;
  final Function({
    String email,
    String password,
  }) onSubmit;

  SignInForm({
    Key key,
    @required this.onForgotDetails,
    @required this.onSubmit,
    this.email,
  }) : super(key: key);

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.email != null) {
      _emailController.text = widget.email;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        ElevatedButton(
          onPressed: _onSubmit,
          child: BodyText1.light('SIGN IN'),
          style: ElevatedButton.styleFrom(
            primary: theme.accentColor,
          ),
        ),
        TextButton(
          onPressed: _onForgotDetails,
          child: BodyText1('FORGOT DETAILS?'),
        ),
      ],
    );
  }

  _onSubmit() {
    if (_formKey.currentState.validate()) {
      widget.onSubmit(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  _onForgotDetails() {
    widget.onForgotDetails(
      email: _emailController.text,
    );
  }

  String _validateEmail(String value) {
    if (value.trim().isEmpty) {
      return 'Email is required';
    } else if (!EmailValidator.validate(value.trim())) {
      return 'Email address is invalid';
    }

    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }

    return null;
  }
}
