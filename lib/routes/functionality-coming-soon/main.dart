import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/navigation.dart';

class ComingSoonScreen extends StatelessWidget {
  static const RELATIVE_PATH = 'comming_soon';
  static const PATH = "/$RELATIVE_PATH";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            'images/coming-soon.png',
            fit: BoxFit.cover,
          ),
          SizedBox(height: 32.0),
          Subtitle1(
            'Coming soon!',
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _onBack,
              child: BodyText1.light('Back'),
            ),
          ),
        ],
      ),
    );
  }

  _onBack() {
    locator<NavigationService>().pop();
  }
}
