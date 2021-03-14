import 'package:flutter/material.dart';
import 'package:mywonderbird/components/settings-list-header.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:provider/provider.dart';

class NotificationSettings extends StatefulWidget {
  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _acceptedNewsletter = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<User>(context, listen: false);

    _acceptedNewsletter = user?.profile?.acceptedNewsletter ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _onSave,
            child: Text(
              'SAVE',
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          SettingsListHeader(
            title: 'COMMUNICATION PREFERENCES',
          ),
          CheckboxListTile(
            value: _acceptedNewsletter,
            onChanged: _onChangeAcceptedNewsletter,
            title: const Text(
              'I accept to receive travel news, tips, app updates and offers to my email',
            ),
          ),
        ],
      ),
    );
  }

  _onChangeAcceptedNewsletter(bool newValue) {
    setState(() {
      _acceptedNewsletter = newValue;
    });
  }

  _onSave() async {
    final user = Provider.of<User>(context, listen: false);
    final navigationService = locator<NavigationService>();

    if (user?.profile?.acceptedNewsletter != _acceptedNewsletter) {
      final profileService = locator<ProfileService>();
      final authService = locator<AuthenticationService>();
      final updatedProfile = await profileService
          .updateCommunicationPreferences(_acceptedNewsletter);

      user.profile = updatedProfile;
      authService.addUser(user);
    }

    navigationService.pop();
  }
}
