import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/providers/terms.dart';
import 'package:mywonderbird/routes/pdf/main.dart';
import 'package:mywonderbird/services/navigation.dart';

class InitialTerms extends StatelessWidget {
  final bool termsAccepted;
  final bool newsletterAccepted;
  final Function onChangedAcceptTerms;
  final Function onChangedAcceptNewsletter;
  final Function onContinue;

  const InitialTerms({
    Key key,
    @required this.termsAccepted,
    @required this.newsletterAccepted,
    @required this.onChangedAcceptTerms,
    @required this.onChangedAcceptNewsletter,
    @required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Terms and conditions',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 8.0,
          ),
        ),
        Text(
          'We are excited to welcome you to MyWonderbird! We hope you will have a great time using our platform.',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 8.0,
          ),
        ),
        _createTermsText(),
        Padding(
          padding: EdgeInsets.only(
            bottom: 16.0,
          ),
        ),
        ..._consent(),
        Padding(
          padding: EdgeInsets.only(
            bottom: 16.0,
          ),
        ),
        ..._actions(context),
      ],
    );
  }

  Widget _createTermsText() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'In order to have an enjoyable experience, please read our ',
          ),
          ..._createTermsLinks(),
          TextSpan(text: ' before you continue.'),
        ],
      ),
      style: TextStyle(
        fontSize: 16.0,
      ),
    );
  }

  List<TextSpan> _createTermsLinks() {
    final termsProvider = locator<TermsProvider>();

    if (termsProvider.termsOfService != null &&
        termsProvider.privacyPolicy != null) {
      return [
        _createTermsOfServiceLink(),
        TextSpan(text: ' and '),
        _createPrivacyPolicyLink(),
      ];
    }

    if (termsProvider.termsOfService != null) {
      return [_createTermsOfServiceLink()];
    }

    if (termsProvider.privacyPolicy != null) {
      return [_createPrivacyPolicyLink()];
    }

    return [];
  }

  TextSpan _createTermsOfServiceLink() {
    return TextSpan(
      text: 'Terms of Service',
      style: TextStyle(
        color: Colors.blue,
      ),
      recognizer: TapGestureRecognizer()..onTap = _viewTermsOfService,
    );
  }

  TextSpan _createPrivacyPolicyLink() {
    return TextSpan(
      text: 'Privacy Policy',
      style: TextStyle(
        color: Colors.blue,
      ),
      recognizer: TapGestureRecognizer()..onTap = _viewPrivacyPolicy,
    );
  }

  _viewPrivacyPolicy() {
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

  _viewTermsOfService() {
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

  List<Widget> _consent() {
    return [
      CheckboxListTile(
        title: const Text('I have read and accept the terms'),
        value: termsAccepted,
        onChanged: onChangedAcceptTerms,
      ),
      Padding(
        padding: EdgeInsets.only(
          bottom: 8.0,
        ),
      ),
      CheckboxListTile(
        title: const Text(
          'I accept to receive travel news, tips, app updates and offers to my email',
        ),
        value: newsletterAccepted,
        onChanged: onChangedAcceptNewsletter,
      ),
    ];
  }

  List<Widget> _actions(BuildContext context) {
    final theme = Theme.of(context);

    return [
      RaisedButton(
        onPressed: termsAccepted ? onContinue : null,
        child: Text('CONTINUE'),
        color: theme.accentColor,
        textColor: Colors.white,
      ),
    ];
  }
}
