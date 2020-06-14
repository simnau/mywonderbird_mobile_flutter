import 'package:flutter/cupertino.dart';
import 'package:layout/types/picture-data.dart';

class SharePictureProvider with ChangeNotifier {
  PictureData pictureData;

  void clearState() {
    pictureData = null;
  }
}
