import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/navigation.dart';

class SavedTripFinished extends StatefulWidget {
  @override
  _SavedTripFinishedState createState() => _SavedTripFinishedState();
}

class _SavedTripFinishedState extends State<SavedTripFinished> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Subtitle1(
              'Congratulations! You finished your trip!',
              textAlign: TextAlign.center,
            ),
            RaisedButton(
              child: BodyText1.light('Share it with friends'),
              onPressed: () {
                print('Share trip');
              },
            ),
            FlatButton(
              child: BodyText1('Close'),
              onPressed: () {
                final navigationService = locator<NavigationService>();

                navigationService.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
