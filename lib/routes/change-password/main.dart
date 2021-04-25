import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/auth.dart';
import 'package:mywonderbird/constants/error-codes.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/change-password/components/change-password-form.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/util/snackbar.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  FocusNode _currentPasswordFocusNode;
  FocusNode _newPasswordFocusNode;
  String _error;

  @override
  void initState() {
    super.initState();

    _currentPasswordFocusNode = FocusNode();
    _newPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Subtitle1('Change password'),
          actions: [
            Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => _onChangePassword(context),
                  child: Text(
                    'SAVE',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                );
              },
            ),
          ],
        ),
        body: ChangePasswordForm(
          error: _error,
          currentPasswordController: _currentPasswordController,
          newPasswordController: _newPasswordController,
          currentPasswordFocusNode: _currentPasswordFocusNode,
          newPasswordFocusNode: _newPasswordFocusNode,
          validateCurrentPassword: _validateCurrentPassword,
          validateNewPassword: _validateNewPassword,
        ),
      ),
    );
  }

  String _validateCurrentPassword(value) {
    if (value.isEmpty) {
      return 'Password is required';
    }

    return null;
  }

  String _validateNewPassword(value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < MIN_PASSWORD_LENGTH) {
      return "Password must be at least $MIN_PASSWORD_LENGTH characters long";
    }

    return null;
  }

  _onChangePassword(BuildContext context) async {
    try {
      setState(() {
        _error = null;
      });
      if (_formKey.currentState.validate()) {
        final authenticationService = locator<AuthenticationService>();

        final currentPassword = _currentPasswordController.text;
        final newPassword = _newPasswordController.text;
        await authenticationService.changePassword(
          currentPassword,
          newPassword,
        );

        _currentPasswordController.clear();
        _newPasswordController.clear();
        _currentPasswordFocusNode.unfocus();
        _newPasswordFocusNode.unfocus();

        final snackBar = createSuccessSnackbar(
          text: 'Password successfully changed',
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on AuthenticationException catch (e) {
      var error;

      switch (e.errorCode) {
        case NOT_AUTHORIZED:
          error = 'Your current password is incorrect';
          break;
        default:
          error = 'There was an error changing your password';
          break;
      }

      final snackBar = createErrorSnackbar(text: error);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final snackBar = createErrorSnackbar(
        text: 'There was an error changing your password',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
