import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/authentication/link-email-password.dart';
import 'package:mywonderbird/services/navigation.dart';

const PASSWORD_PROVIDER = 'password';
const FACEBOOK_PROVIDER = 'facebook.com';
const GOOGLE_PROVIDER = 'google.com';
const APPLE_PROVIDER = 'apple.com';

class LinkAccountDialog extends StatelessWidget {
  final List<String> providers;
  final String email;
  final String message;

  const LinkAccountDialog({
    Key key,
    @required this.providers,
    @required this.email,
    String message,
  })  : this.message = message ??
            'An account with this email already exists. Sign in using one of these methods to link your account.',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Subtitle1(
              message,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ListView.separated(
              itemBuilder: _providerItem,
              separatorBuilder: separatorBuilder,
              itemCount: providers.length,
              shrinkWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerItem(BuildContext context, int providerIndex) {
    final provider = providers[providerIndex];

    switch (provider) {
      case PASSWORD_PROVIDER:
        return _passwordItem(context);
      case FACEBOOK_PROVIDER:
        return _facebookItem(context);
      case GOOGLE_PROVIDER:
        return _googleItem(context);
      case APPLE_PROVIDER:
        return _appleItem(context);
      default:
        return null;
    }
  }

  Widget _passwordItem(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: _emailPasswordLink,
      child: BodyText1.light('EMAIL AND PASSWORD'),
      style: ElevatedButton.styleFrom(
        primary: theme.accentColor,
      ),
    );
  }

  Widget _facebookItem(BuildContext context) {
    return ElevatedButton(
      onPressed: _facebookLink,
      child: BodyText1.light('FACEBOOK'),
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF3B5798),
      ),
    );
  }

  Widget _googleItem(BuildContext context) {
    return ElevatedButton(
      onPressed: _googleLink,
      child: BodyText1.light('GOOGLE'),
      style: ElevatedButton.styleFrom(
        primary: Color(0xFFDB4437),
      ),
    );
  }

  Widget _appleItem(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print('Pressed apple');
      },
      child: Text('APPLE'),
    );
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return SizedBox(height: 8);
  }

  _emailPasswordLink() async {
    final navigationService = locator<NavigationService>();
    final credential = await navigationService.push(
      MaterialPageRoute(
        builder: (_) => LinkEmailPassword(
          email: email,
        ),
      ),
    );

    navigationService.pop(credential);
  }

  _facebookLink() async {
    final result = await FacebookAuth.instance.login();

    if (result.status != LoginStatus.success) {
      return null;
    }

    final credential =
        FacebookAuthProvider.credential(result.accessToken.token);

    final navigationService = locator<NavigationService>();

    navigationService.pop(credential);
  }

  _googleLink() async {
    final googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return null;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final navigationService = locator<NavigationService>();

    navigationService.pop(credential);
  }
}
