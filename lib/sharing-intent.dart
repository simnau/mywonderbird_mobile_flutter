import 'dart:async';

import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/routes/share-picture/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/picture-data.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'locator.dart';

class SharingIntent {
  StreamSubscription _intentDataStreamSubscription;

  setupSharingIntentListeners() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value == null) {
        return;
      }

      for (var image in value) {
        _handleShare(image.path);
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value == null) {
        return;
      }

      for (var image in value) {
        _handleShare(image.path);
      }
    });
  }

  dispose() {
    _intentDataStreamSubscription.cancel();
  }

  _handleShare(String filePath) async {
    final pictureDataService = locator<PictureDataService>();
    final pictureData = await pictureDataService.extractPictureData(filePath);

    final sharePictureProvider = locator<SharePictureProvider>();

    sharePictureProvider.pictureData = pictureData;
    locator<NavigationService>().pushReplacementNamed(ShareScreen.PATH);
  }
}
