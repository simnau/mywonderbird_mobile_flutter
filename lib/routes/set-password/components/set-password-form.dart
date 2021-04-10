import 'package:flutter/material.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';

class SetPasswordForm extends StatelessWidget {
  final String error;
  final TextEditingController newPasswordController;
  final FocusNode newPasswordFocusNode;
  final String Function(String) validateNewPassword;

  const SetPasswordForm({
    Key key,
    this.error,
    this.newPasswordController,
    this.newPasswordFocusNode,
    this.validateNewPassword,
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
              child: BodyText1.light(error),
            ),
          AuthTextField(
            controller: newPasswordController,
            focusNode: newPasswordFocusNode,
            validator: validateNewPassword,
            labelText: 'New password',
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
