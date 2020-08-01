import 'dart:io';

import 'package:layout/services/api.dart';

const BOOKMARK_GEM_CAPTURE_PATH = '/api/bookmarks/gem-captures';
final unbookmarkGemCapturePath =
    (gemCaptureId) => "$BOOKMARK_GEM_CAPTURE_PATH/$gemCaptureId";

class BookmarkService {
  final API api;

  BookmarkService({this.api});

  bookmarkGemCapture(String gemCaptureId) async {
    final response = await api.post(BOOKMARK_GEM_CAPTURE_PATH, {
      'gemCaptureId': gemCaptureId,
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error bookmarking the Gem Capture');
    }
  }

  unbookmarkGemCapture(String gemCaptureId) async {
    final response = await api.delete(unbookmarkGemCapturePath(gemCaptureId));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error unbookmarking the Gem Capture');
    }
  }
}
