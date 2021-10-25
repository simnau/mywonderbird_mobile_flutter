import 'package:flutter/material.dart';
import 'package:mywonderbird/models/location.dart';

class PictureData {
  final List<ImageProvider> images;
  final List<String> imagePaths;
  final LocationModel location;
  final DateTime creationDate;

  PictureData({
    @required this.images,
    @required this.imagePaths,
    @required this.location,
    @required this.creationDate,
  });
}
