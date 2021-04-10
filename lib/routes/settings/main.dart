import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mywonderbird/components/link-account-dialog.dart';
import 'package:mywonderbird/components/settings-list-header.dart';
import 'package:mywonderbird/components/settings-list-icon.dart';
import 'package:mywonderbird/components/settings-list-item.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/providers/terms.dart';
import 'package:mywonderbird/routes/authentication/select-auth-option.dart';
import 'package:mywonderbird/routes/change-password/main.dart';
import 'package:mywonderbird/routes/feedback/form/main.dart';
import 'package:mywonderbird/routes/notification-settings/main.dart';
import 'package:mywonderbird/routes/pdf/main.dart';
import 'package:mywonderbird/routes/profile-settings/main.dart';
import 'package:mywonderbird/routes/set-password/main.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/defaults.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:provider/provider.dart';

final socialProviders = Platform.isIOS
    ? [APPLE_PROVIDER, GOOGLE_PROVIDER, FACEBOOK_PROVIDER]
    : [GOOGLE_PROVIDER, FACEBOOK_PROVIDER];

class Settings extends StatefulWidget {
  static const RELATIVE_PATH = 'settings';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
          ..._signInMethods(),
          ..._passwordItem(context),
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

  List<Widget> _signInMethods() {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final user = Provider.of<User>(context);
    final List<Widget> results = [];
    final theme = Theme.of(context);

    for (final provider in socialProviders) {
      final hasProvider = currentUser.providerData
          .where((p) => p.providerId == provider)
          .isNotEmpty;
      // If it's the only login method, we don't allow to unlink
      final canUnlink = user.providers.length > 1;
      final onPressed =
          () => hasProvider ? _onUnlink(provider) : _onLink(provider);

      var color;

      if (hasProvider && canUnlink) {
        color = theme.errorColor;
      }

      final conditionalOnPressed = hasProvider && !canUnlink ? null : onPressed;
      final buttonText = hasProvider ? 'Unlink' : 'Link';

      switch (provider) {
        case FACEBOOK_PROVIDER:
          results.add(
            SettingsListItem(
              icon: SettingsListIcon(
                icon: MaterialCommunityIcons.facebook,
                color: Colors.white,
                backgroundColor: Color(0xFF3B5798),
              ),
              title: 'Facebook',
              trailing: TextButton(
                child: Subtitle2(
                  buttonText,
                  color: color,
                ),
                onPressed: conditionalOnPressed,
              ),
            ),
          );
          results.add(Divider());
          break;
        case GOOGLE_PROVIDER:
          results.add(
            SettingsListItem(
              icon: SettingsListIcon(
                icon: MaterialCommunityIcons.google,
                color: Colors.white,
                backgroundColor: Color(0xFFDB4437),
              ),
              title: 'Google',
              trailing: TextButton(
                child: Subtitle2(
                  buttonText,
                  color: color,
                ),
                onPressed: conditionalOnPressed,
              ),
            ),
          );
          results.add(Divider());
          break;
        case APPLE_PROVIDER:
          results.add(
            SettingsListItem(
              icon: SettingsListIcon(
                icon: MaterialCommunityIcons.apple,
                color: Colors.white,
                backgroundColor: Colors.black,
              ),
              title: 'Apple',
              trailing: TextButton(
                child: Subtitle2(
                  buttonText,
                  color: color,
                ),
                onPressed: conditionalOnPressed,
              ),
            ),
          );
          results.add(Divider());
          break;
      }
    }

    return results;
  }

  List<Widget> _passwordItem(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user?.providers == null ||
        !user.providers.contains(PASSWORD_PROVIDER)) {
      return [
        SettingsListItem(
          onTap: _onSetPassword,
          icon: SettingsListIcon(
            icon: Icons.vpn_key,
            color: Colors.white,
            backgroundColor: Colors.black87,
          ),
          title: 'Set password',
        ),
        Divider(),
      ];
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

  _onSetPassword() {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (context) => SetPassword(),
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

  _onLink(provider) {
    switch (provider) {
      case FACEBOOK_PROVIDER:
        return _linkFacebook();
      case GOOGLE_PROVIDER:
        return _linkGoogle();
      case APPLE_PROVIDER:
        return _linkApple();
    }
  }

  _onUnlink(provider) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final user = Provider.of<User>(context, listen: false);
    final authenticationService = locator<AuthenticationService>();

    await currentUser.unlink(provider);

    final newProviders = [...user.providers];
    newProviders.remove(provider);

    authenticationService.addUser(User(
      id: user.id,
      role: user.role,
      provider: user.provider,
      providers: newProviders,
      profile: user.profile,
    ));
  }

  _linkFacebook() async {
    final result = await FacebookAuth.instance.login();

    switch (result.status) {
      case LoginStatus.cancelled:
        return;
      case LoginStatus.failed:
        return;
      case LoginStatus.operationInProgress:
        return;
      default:
        final credential =
            auth.FacebookAuthProvider.credential(result.accessToken.token);
        final currentUser = auth.FirebaseAuth.instance.currentUser;
        final user = Provider.of<User>(context, listen: false);
        final authenticationService = locator<AuthenticationService>();

        final providers = await auth.FirebaseAuth.instance
            .fetchSignInMethodsForEmail(currentUser.email);

        final oldCredential = await showDialog(
          context: context,
          builder: (context) => LinkAccountDialog(
            providers: providers,
            email: currentUser.email,
            message: 'Please re-sign-in to link the account',
          ),
        );

        if (credential != null) {
          await auth.FirebaseAuth.instance.signInWithCredential(oldCredential);
          await auth.FirebaseAuth.instance.currentUser
              .linkWithCredential(credential);

          final newProviders = [
            ...user.providers,
            FACEBOOK_PROVIDER,
          ];

          authenticationService.addUser(User(
            id: user.id,
            role: user.role,
            provider: user.provider,
            providers: newProviders,
            profile: user.profile,
          ));
        }
    }
  }

  _linkGoogle() async {
    final googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return;
    }

    final googleAuth = await googleUser.authentication;

    final credential = auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final user = Provider.of<User>(context, listen: false);
    final authenticationService = locator<AuthenticationService>();

    final providers = await auth.FirebaseAuth.instance
        .fetchSignInMethodsForEmail(currentUser.email);

    final oldCredential = await showDialog(
      context: context,
      builder: (context) => LinkAccountDialog(
        providers: providers,
        email: googleUser.email,
        message: 'Please re-sign-in to link the account',
      ),
    );

    if (credential != null) {
      await auth.FirebaseAuth.instance.signInWithCredential(oldCredential);
      await auth.FirebaseAuth.instance.currentUser
          .linkWithCredential(credential);

      final newProviders = [
        ...user.providers,
        GOOGLE_PROVIDER,
      ];

      authenticationService.addUser(User(
        id: user.id,
        role: user.role,
        provider: user.provider,
        providers: newProviders,
        profile: user.profile,
      ));
    }
  }

  _linkApple() {}
}
