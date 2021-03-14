import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/functionality-coming-soon/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/routes/feedback/main.dart';

class SavedTripFinished extends StatefulWidget {
  final String id;

  const SavedTripFinished({
    Key key,
    this.id,
  }) : super(key: key);

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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              'images/congratulations.png',
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Subtitle1(
                    'Congratulations! You finished your trip!',
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    child: BodyText1.light('Share it with friends'),
                    onPressed: _onShareTrip,
                  ),
                  TextButton(
                    child: BodyText1('Close'),
                    onPressed: () {
                      locator<NavigationService>().pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => FeedbackScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onShareTrip() {
    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: SHARE_SAVED, parameters: {
      'saved_trip_id': widget.id,
    });
    locator<NavigationService>().pushNamed(ComingSoonScreen.PATH);
  }
}
