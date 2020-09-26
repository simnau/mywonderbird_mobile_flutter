import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/suggest-trip-questionnaire/main.dart';
import 'package:mywonderbird/services/navigation.dart';

class SuggestTrip extends StatefulWidget {
  @override
  _SuggestTripState createState() => _SuggestTripState();
}

class _SuggestTripState extends State<SuggestTrip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.asset(
              'images/onboarding/3.png',
              fit: BoxFit.cover,
            ),
          ),
          _bottomContent(),
        ],
      ),
    );
  }

  Widget _bottomContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tell us about your trip',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
          ),
          Text(
            'In order for us to give you better suggestions, please let us know more about your trip',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
          ),
          RaisedButton(
            colorBrightness: Brightness.dark,
            onPressed: _onStart,
            child: Text(
              'Start',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onStart() {
    final navigationService = locator<NavigationService>();
    navigationService.pushReplacement(
      MaterialPageRoute(builder: (context) => SuggestTripQuestionnaire()),
    );
  }
}
