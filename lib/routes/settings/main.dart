import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/authentication/select-auth-option.dart';
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
        children: [
          _subHeader('GENERAL SETTINGS'),
          _listItem(
            onTap: _onProfile,
            icon: _listIcon(
              icon: Icons.person,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Profile settings',
          ),
          Divider(),
          _listItem(
            onTap: _onNotifications,
            icon: _listIcon(
              icon: Icons.notifications,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Notifications',
          ),
          Divider(),
          _listItem(
            onTap: _onSignOut,
            icon: _listIcon(
              icon: MaterialCommunityIcons.logout_variant,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Sign out',
          ),
          _subHeader('FEEDBACK'),
          _listItem(
            onTap: _onFeedback,
            icon: _listIcon(
              icon: Icons.feedback,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Give feedback',
          ),
          Divider(),
          _listItem(
            onTap: _onReportBug,
            icon: _listIcon(
              icon: Icons.bug_report,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Report a bug',
          ),
          _subHeader('LEGAL'),
          _listItem(
            onTap: _onPrivacy,
            icon: _listIcon(
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

  Widget _listItem({
    void Function() onTap,
    Widget icon,
    String title,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      leading: icon,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 18.0,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
      ),
    );
  }

  Widget _listIcon({IconData icon, Color color, Color backgroundColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }

  Widget _subHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        ),
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

  _onFeedback() {}

  _onReportBug() {}

  _onPrivacy() {}

  _navigateToLogin() async {
    final navigationService = locator<NavigationService>();
    navigationService.popUntil((route) => route.isFirst);
    navigationService.pushReplacementNamed(SelectAuthOption.PATH);
  }
}
