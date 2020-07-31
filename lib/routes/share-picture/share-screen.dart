import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/journey.dart';
import 'package:layout/routes/home/main.dart';
import 'package:layout/routes/share-picture/components/sharing-widget.dart';
import 'package:layout/services/navigation.dart';

class ShareScreen extends StatelessWidget {
  static const RELATIVE_PATH = 'share-picture/share';
  static const PATH = "/$RELATIVE_PATH";

  final Journey selectedJourney;

  ShareScreen({this.selectedJourney});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: _cancel,
          )
        ],
      ),
      body: SharingWidget(
        selectedJourney: selectedJourney,
      ),
    );
  }

  void _cancel() {
    locator<NavigationService>().popUntil((route) => route.isFirst);
    locator<NavigationService>().pushReplacementNamed(HomePage.PATH);
  }
}
