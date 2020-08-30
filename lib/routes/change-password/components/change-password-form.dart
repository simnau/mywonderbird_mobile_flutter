import 'package:flutter/material.dart';
import 'package:mywonderbird/components/auth-text-field.dart';

class ChangePasswordForm extends StatelessWidget {
  final String error;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final FocusNode currentPasswordFocusNode;
  final FocusNode newPasswordFocusNode;
  final String Function(String) validatePassword;

  const ChangePasswordForm({
    Key key,
    this.error,
    this.currentPasswordController,
    this.newPasswordController,
    this.currentPasswordFocusNode,
    this.newPasswordFocusNode,
    this.validatePassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (error != null)
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              color: Colors.red,
              child: Text(
                error,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          AuthTextField(
            controller: currentPasswordController,
            focusNode: currentPasswordFocusNode,
            validator: validatePassword,
            labelText: 'Current password',
            obscureText: true,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
          ),
          AuthTextField(
            controller: newPasswordController,
            focusNode: newPasswordFocusNode,
            validator: validatePassword,
            labelText: 'New password',
            obscureText: true,
          ),
        ],
      ),
    );
    ;
  }
}
