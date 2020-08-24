import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/providers/terms.dart';
import 'package:mywonderbird/routes/pdf/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/types/pdf-arguments.dart';

class UpdatedTerms extends StatelessWidget {
  final bool termsAccepted;
  final Function onChangedAcceptTerms;
  final Function onContinue;

  const UpdatedTerms({
    Key key,
    @required this.termsAccepted,
    @required this.onChangedAcceptTerms,
    @required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Our terms have updated',
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
            text: 'Please take a moment to review the updated ',
          ),
          ..._createTermsLinks(),
          TextSpan(text: ' to continue enjoying our platform!'),
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

    locator<NavigationService>().pushNamed(
      PdfPage.PATH,
      arguments: PdfArguments(
        title: 'Privacy policy',
        url: termsProvider.privacyPolicy.url,
      ),
    );
  }

  _viewTermsOfService() {
    final termsProvider = locator<TermsProvider>();

    locator<NavigationService>().pushNamed(
      PdfPage.PATH,
      arguments: PdfArguments(
        title: 'Terms of service',
        url: termsProvider.termsOfService.url,
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
