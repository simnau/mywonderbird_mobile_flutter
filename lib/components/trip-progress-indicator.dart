import 'package:flutter/material.dart';
import 'package:mywonderbird/models/journey.dart';

import 'typography/subtitle2.dart';

class TripProgressIndicator extends StatelessWidget {
  final Journey trip;

  const TripProgressIndicator({
    Key key,
    @required this.trip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (trip.finishDate != null) {
      return Subtitle2(
        'Finished',
        color: Colors.green[900],
      );
    }

    if (trip.startDate != null) {
      return Subtitle2(
        'In progress',
        color: Colors.orange[900],
      );
    }

    return Subtitle2(
      'Ready to start',
      color: Colors.blue[900],
    );
  }
}
