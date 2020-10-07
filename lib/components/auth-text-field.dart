import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String Function(String) validator;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;

  const AuthTextField({
    Key key,
    this.controller,
    this.focusNode,
    this.validator,
    this.labelText,
    this.keyboardType,
    this.obscureText = false,
  }) : super(key: key);

  @override
  _AuthTextFieldState createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool obscureText;

  @override
  void initState() {
    super.initState();
    obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textFieldTheme = theme.copyWith(
      hintColor: Colors.black,
      primaryColor: theme.primaryColorDark,
    );

    return Theme(
      data: textFieldTheme,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          errorStyle: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          suffixIcon: widget.obscureText ? _viewPasswordIcon() : null,
        ),
        style: theme.textTheme.subtitle1,
        keyboardType: widget.keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  Widget _viewPasswordIcon() {
    return IconButton(
      icon: Icon(
        obscureText
            ? MaterialCommunityIcons.eye
            : MaterialCommunityIcons.eye_off,
      ),
      onPressed: _toggleShowPassword,
    );
  }

  _toggleShowPassword() {
    setState(() {
      obscureText = !obscureText;
    });
  }
}
