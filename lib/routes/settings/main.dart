import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/settings-list-header.dart';
import 'package:mywonderbird/components/settings-list-icon.dart';
import 'package:mywonderbird/components/settings-list-item.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/authentication/select-auth-option.dart';
import 'package:mywonderbird/routes/change-password/main.dart';
import 'package:mywonderbird/routes/notification-settings/main.dart';
import 'package:mywonderbird/routes/profile-settings/main.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/navigation.dart';

class Settings extends StatelessWidget {
  static const RELATIVE_PATH = 'settings';
  static const PATH = "/$RELATIVE_PATH";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16.0),
        children: [
          SettingsListHeader(title: 'GENERAL SETTINGS'),
          SettingsListItem(
            onTap: _onProfile,
            icon: SettingsListIcon(
              icon: Icons.person,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Profile settings',
          ),
          Divider(),
          SettingsListItem(
            onTap: _onNotifications,
            icon: SettingsListIcon(
              icon: Icons.notifications,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Notifications',
          ),
          Divider(),
          SettingsListItem(
            onTap: _onChangePassword,
            icon: SettingsListIcon(
              icon: Icons.vpn_key,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Change password',
          ),
          Divider(),
          SettingsListItem(
            onTap: _onSignOut,
            icon: SettingsListIcon(
              icon: MaterialCommunityIcons.logout_variant,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Sign out',
          ),
          SettingsListHeader(title: 'FEEDBACK'),
          SettingsListItem(
            onTap: _onFeedback,
            icon: SettingsListIcon(
              icon: Icons.feedback,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Give feedback',
          ),
          Divider(),
          SettingsListItem(
            onTap: _onReportBug,
            icon: SettingsListIcon(
              icon: Icons.bug_report,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Report a bug',
          ),
          SettingsListHeader(title: 'LEGAL'),
          SettingsListItem(
            onTap: _onPrivacy,
            icon: SettingsListIcon(
              icon: FontAwesome.book,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Privacy',
          ),
        ],
      ),
    );
  }

  _onSignOut() async {
    final user = await locator<AuthenticationService>().signOut();

    if (user == null) {
      _navigateToLogin();
    }
  }

  _onProfile() {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => ProfileSettings(),
    ));
  }

  _onNotifications() {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => NotificationSettings(),
    ));
  }

  _onChangePassword() {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => ChangePassword(),
    ));
  }

  _onFeedback() {}

  _onReportBug() {}

  _onPrivacy() {}

  _navigateToLogin() async {
    final navigationService = locator<NavigationService>();
    navigationService.popUntil((route) => route.isFirst);
    navigationService.pushReplacementNamed(SelectAuthOption.PATH);
  }
}
