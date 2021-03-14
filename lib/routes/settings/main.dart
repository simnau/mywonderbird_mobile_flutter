import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/settings-list-header.dart';
import 'package:mywonderbird/components/settings-list-icon.dart';
import 'package:mywonderbird/components/settings-list-item.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/auth.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/providers/terms.dart';
import 'package:mywonderbird/routes/authentication/select-auth-option.dart';
import 'package:mywonderbird/routes/change-password/main.dart';
import 'package:mywonderbird/routes/feedback/form/main.dart';
import 'package:mywonderbird/routes/notification-settings/main.dart';
import 'package:mywonderbird/routes/pdf/main.dart';
import 'package:mywonderbird/routes/profile-settings/main.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/defaults.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  static const RELATIVE_PATH = 'settings';
  static const PATH = "/$RELATIVE_PATH";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Subtitle1('Settings'),
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
          ..._changePasswordItem(context),
          // TODO: add this back once it's relevant to the user
          // Builder(
          //   builder: (context) => SettingsListItem(
          //     onTap: () => _onResetToDefaults(context),
          //     icon: SettingsListIcon(
          //       icon: Icons.settings_backup_restore,
          //       color: Colors.white,
          //       backgroundColor: Colors.black87,
          //     ),
          //     title: 'Reset to defaults',
          //     hideTrailing: true,
          //   ),
          // ),
          // Divider(),
          SettingsListItem(
            onTap: _onSignOut,
            icon: SettingsListIcon(
              icon: MaterialCommunityIcons.logout_variant,
              color: Colors.white,
              backgroundColor: Colors.black87,
            ),
            title: 'Sign out',
            hideTrailing: true,
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
          // TODO: Implement Report Bug functionality
          // Divider(),
          // SettingsListItem(
          //   onTap: _onReportBug,
          //   icon: SettingsListIcon(
          //     icon: Icons.bug_report,
          //     color: Colors.white,
          //     backgroundColor: Colors.black87,
          //   ),
          //   title: 'Report a bug',
          // ),
          SettingsListHeader(title: 'LEGAL'),
          ..._legalWidgets(),
        ],
      ),
    );
  }

  List<Widget> _changePasswordItem(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user?.provider != COGNITO_PROVIDER) {
      return [];
    }

    return [
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
    ];
  }

  List<Widget> _legalWidgets() {
    final termsProvider = locator<TermsProvider>();

    if (termsProvider.privacyPolicy != null &&
        termsProvider.termsOfService != null) {
      return [
        _termsWidget(),
        Divider(),
        _privacyWidget(),
      ];
    }

    if (termsProvider.termsOfService != null) {
      return [_termsWidget()];
    }

    if (termsProvider.privacyPolicy != null) {
      return [_privacyWidget()];
    }

    return [];
  }

  Widget _termsWidget() {
    return SettingsListItem(
      onTap: _onTermsOfService,
      icon: SettingsListIcon(
        icon: FontAwesome.book,
        color: Colors.white,
        backgroundColor: Colors.black87,
      ),
      title: 'Terms of service',
    );
  }

  Widget _privacyWidget() {
    return SettingsListItem(
      onTap: _onPrivacy,
      icon: SettingsListIcon(
        icon: FontAwesome.book,
        color: Colors.white,
        backgroundColor: Colors.black87,
      ),
      title: 'Privacy policy',
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

  _onResetToDefaults(BuildContext context) async {
    final defaultsService = locator<DefaultsService>();
    await defaultsService.reset();

    final snackBar = SnackBar(
      content: Text(
        'App defaults have been reset',
        style: TextStyle(
          color: Colors.green,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _onFeedback() {
    locator<NavigationService>().pushNamed(FeedbackForm.PATH);
  }

  _onReportBug() {}

  _onTermsOfService() {
    final termsProvider = locator<TermsProvider>();

    locator<NavigationService>().push(
      MaterialPageRoute(
        builder: (context) => PdfPage(
          url: termsProvider.termsOfService.url,
          title: 'Terms of service',
        ),
      ),
    );
  }

  _onPrivacy() {
    final termsProvider = locator<TermsProvider>();

    locator<NavigationService>().push(
      MaterialPageRoute(
        builder: (context) => PdfPage(
          url: termsProvider.privacyPolicy.url,
          title: 'Privacy policy',
        ),
      ),
    );
  }

  _navigateToLogin() async {
    final navigationService = locator<NavigationService>();
    navigationService.popUntil((route) => route.isFirst);
    navigationService.pushReplacementNamed(SelectAuthOption.PATH);
  }
}
