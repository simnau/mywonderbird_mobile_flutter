import 'package:flutter/material.dart';
import 'package:layout/models/journey.dart';
import 'package:layout/routes/share-picture/components/sharing-widget.dart';

class ShareScreen extends StatelessWidget {
  static const RELATIVE_PATH = 'share-picture';
  static const PATH = "/$RELATIVE_PATH";

  final Journey selectedJourney;

  ShareScreen({this.selectedJourney});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SharingWidget(
        selectedJourney: selectedJourney,
      ),
    );
  }
}
