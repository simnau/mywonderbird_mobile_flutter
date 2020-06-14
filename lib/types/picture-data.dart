import 'package:flutter/material.dart';
import 'package:layout/models/location.dart';

class PictureData {
  final ImageProvider image;
  final Location location;

  PictureData({
    @required this.image,
    @required this.location,
  });
}
