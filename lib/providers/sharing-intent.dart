import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/select-upload-type/main.dart';
import 'package:mywonderbird/services/navigation.dart';

class SharingIntentProvider with ChangeNotifier {
  List<String> sharedImagePaths;
  bool _applicationLoadComplete = false;
  String _deepLink;

  set applicationLoadComplete(bool value) {
    _applicationLoadComplete = value;
    notifyListeners();
  }

  get applicationLoadComplete {
    return _applicationLoadComplete;
  }

  set deepLink(String value) {
    _deepLink = value;
    notifyListeners();
  }

  get deepLink {
    return _deepLink;
  }

  handleShareImages(List<String> imagePaths) {
    final navigationService = locator<NavigationService>();

    navigationService.push(
      MaterialPageRoute(
        builder: (context) => SelectUploadType(
          imagePaths: imagePaths,
        ),
      ),
    );
  }
}
