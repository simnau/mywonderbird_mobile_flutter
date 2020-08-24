import 'package:flutter/cupertino.dart';
import 'package:mywonderbird/types/picture-data.dart';

class SharePictureProvider with ChangeNotifier {
  PictureData pictureData;

  void clearState() {
    pictureData = null;
  }
}
