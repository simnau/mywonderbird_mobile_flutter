import 'package:flutter/material.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/util/date.dart';
import 'package:mywonderbird/util/json.dart';

class PictureData {
  final ImageProvider image; // TODO: remove when select picture works
  final String imagePath;
  final LocationModel location;
  final DateTime creationDate;

  PictureData({
    @required this.image,
    @required this.imagePath,
    @required this.location,
    @required this.creationDate,
  });

  Map<String, dynamic> toJson() {
    return removeNulls({
      'imagePath': imagePath,
      'location': location?.toJson(),
      'creationDate': formatDateTime(creationDate),
    });
  }
}
