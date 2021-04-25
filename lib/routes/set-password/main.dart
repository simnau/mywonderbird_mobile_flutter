import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/link-account-dialog.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/auth.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/routes/set-password/components/set-password-form.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:provider/provider.dart';

class SetPassword extends StatefulWidget {
  @override
  _SetPasswordState createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  FocusNode _newPasswordFocusNode;
  String _error;

  @override
  void initState() {
    super.initState();

    _newPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
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
          title: Subtitle1('Set password'),
          actions: [
            Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => _onSubmit(context),
                  child: Text(
                    'SAVE',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                );
              },
            ),
          ],
        ),
        body: SetPasswordForm(
          error: _error,
          newPasswordController: _newPasswordController,
          newPasswordFocusNode: _newPasswordFocusNode,
          validateNewPassword: _validateNewPassword,
        ),
      ),
    );
  }

  String _validateNewPassword(value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < MIN_PASSWORD_LENGTH) {
      return "Password must be at least $MIN_PASSWORD_LENGTH characters long";
    }

    return null;
  }

  _onSubmit(BuildContext context) async {
    try {
      setState(() {
        _error = null;
      });
      if (_formKey.currentState.validate()) {
        final authenticationService = locator<AuthenticationService>();
        final user = Provider.of<User>(context, listen: false);

        final currentUser = auth.FirebaseAuth.instance.currentUser;
        final providers = await auth.FirebaseAuth.instance
            .fetchSignInMethodsForEmail(currentUser.email);

        final newPassword = _newPasswordController.text;

        final oldCredential = await showDialog(
          context: context,
          builder: (context) => LinkAccountDialog(
            providers: providers,
            email: currentUser.email,
            message: 'Please re-sign-in to set a password',
          ),
        );
        if (oldCredential != null) {
          await auth.FirebaseAuth.instance.signInWithCredential(oldCredential);

          final emailPasswordCredentials = auth.EmailAuthProvider.credential(
            email: currentUser.email,
            password: newPassword,
          );

          await currentUser.linkWithCredential(emailPasswordCredentials);

          _newPasswordController.clear();
          _newPasswordFocusNode.unfocus();

          final newUser = auth.FirebaseAuth.instance.currentUser;

          final providers = newUser.providerData
              .map<String>(
                (p) => p.providerId?.toString(),
              )
              .toList();
          final newAppUser = User(
            id: user.id,
            profile: user.profile,
            provider: user.provider,
            providers: providers,
            role: user.role,
          );

          authenticationService.addUser(newAppUser);

          final snackBar = createSuccessSnackbar(
            text: 'Password successfully set for the account',
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (e) {
      setState(() {
        _error = 'There was an error setting the password';
      });
    }
  }
}
