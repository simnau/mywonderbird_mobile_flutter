import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'locator.dart';
import 'providers/sharing-intent.dart';

class SharingIntent {
  StreamSubscription _intentDataStreamSubscription;

  setupSharingIntentListeners() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value == null) {
        return;
      }

      final imagePaths = value
          .where((e) => e.type == SharedMediaType.IMAGE)
          .map((e) => e.path)
          .toList();

      final sharingIntentProvider = locator<SharingIntentProvider>();

      sharingIntentProvider.handleShareImages(imagePaths);
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value == null) {
        return;
      }

      final sharingIntentProvider = locator<SharingIntentProvider>();

      final imagePaths = value
          .where((e) => e.type == SharedMediaType.IMAGE)
          .map((e) => e.path)
          .toList();

      if (imagePaths.isEmpty) {
        return;
      }

      if (sharingIntentProvider.applicationLoadComplete) {
        sharingIntentProvider.handleShareImages(imagePaths);
      } else {
        sharingIntentProvider.sharedImagePaths = imagePaths;
      }
    });
  }

  dispose() {
    _intentDataStreamSubscription.cancel();
  }
}
