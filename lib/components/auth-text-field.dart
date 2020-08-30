import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textFieldTheme = theme.copyWith(
      hintColor: Colors.black,
      primaryColor: theme.primaryColorDark,
    );

    return Theme(
      data: textFieldTheme,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
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
          color: Colors.black87,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
}
