import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/select-upload-type/main.dart';
import 'package:mywonderbird/services/navigation.dart';

class SharingIntentProvider with ChangeNotifier {
  List<String> sharedImagePaths;
  bool applicationLoadComplete = false;

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
