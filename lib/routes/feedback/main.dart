import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/routes/feedback/form/main.dart';
import 'package:mywonderbird/services/navigation.dart';

import '../../locator.dart';

class FeedbackScreen extends StatelessWidget {
  static const RELATIVE_PATH = 'feedback';
  static const PATH = "/$RELATIVE_PATH";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Image.asset(
                'images/feedback/1.png',
                fit: BoxFit.cover,
              ),
            ),
            _bottomContent(),
          ],
        ));
  }

  Widget _bottomContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Subtitle1(
            'Help us improve!',
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
          ),
          ElevatedButton(
            onPressed: _onStart,
            child: BodyText1.light('Write feedback'),
          ),
          TextButton(
            child: BodyText1('Skip'),
            onPressed: () {
              final navigationService = locator<NavigationService>();
              navigationService.pop();
            },
          ),
        ],
      ),
    );
  }

  _onStart() {
    final navigationService = locator<NavigationService>();
    navigationService.pushReplacementNamed(FeedbackForm.PATH);
  }
}
