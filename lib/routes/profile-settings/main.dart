import 'package:flutter/material.dart';
import 'package:mywonderbird/components/settings-list-header.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:provider/provider.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<User>(context, listen: false);

    _usernameController.text = user?.profile?.username;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          FlatButton(
            onPressed: _onSave,
            child: Text(
              'SAVE',
              style: TextStyle(color: theme.primaryColor),
            ),
            shape: ContinuousRectangleBorder(),
          ),
        ],
      ),
      body: Container(
        child: ListView(
          children: [
            SettingsListHeader(
              title: 'ACCOUNT DETAILS',
            ),
            ListTile(
              title: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  errorStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onSave() async {
    final username = _usernameController.text;

    if (username.isEmpty) {
      return;
    }

    final profileService = locator<ProfileService>();
    final authService = locator<AuthenticationService>();
    final navigationService = locator<NavigationService>();

    final user = Provider.of<User>(context, listen: false);
    final updatedProfile = await profileService.updateUserProfile(
      UserProfile(
        username: username,
      ),
    );

    user.profile = updatedProfile;
    authService.addUser(user);

    navigationService.pop();
  }
}
