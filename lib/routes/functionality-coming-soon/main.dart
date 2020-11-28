import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/services/navigation.dart';

import '../../locator.dart';

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
            Stack(alignment: Alignment.center, children: [
              Container(
                  child: Image.asset(
                'images/coming-soon.png',
                fit: BoxFit.cover,
              )),
              Positioned(
                top: 0,
                bottom: -300,
                left: 0,
                right: 0,
                child: Align(
                    child: Subtitle1(
                  'Coming soon!',
                  textAlign: TextAlign.center,
                )),
              ),
            ]),
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
          RaisedButton(
            onPressed: _onBack,
            child: BodyText1.light('Back'),
          ),
        ],
      ),
    );
  }

  _onBack() {
    locator<NavigationService>().pop();
  }
}
