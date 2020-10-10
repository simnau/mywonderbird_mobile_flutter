import 'package:flutter/material.dart';
import 'package:mywonderbird/util/json.dart';

class SavedTripLocation {
  final int sequenceNumber;
  final String placeId;

  SavedTripLocation({
    @required this.sequenceNumber,
    @required this.placeId,
  });

  Map<String, dynamic> toJson() {
    return removeNulls({
      'sequenceNumber': sequenceNumber,
      'placeId': placeId,
    });
  }
}
