import 'dart:io';

import 'package:mywonderbird/services/api.dart';

const LIKE_GEM_CAPTURE_PATH = '/api/likes/gem-captures';
final unlikeGemCapturePath =
    (gemCaptureId) => "$LIKE_GEM_CAPTURE_PATH/$gemCaptureId";

class LikeService {
  final API api;

  LikeService({this.api});

  likeGemCapture(String gemCaptureId) async {
    final response = await api.post(LIKE_GEM_CAPTURE_PATH, {
      'gemCaptureId': gemCaptureId,
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error liking the Gem Capture');
    }
  }

  unlikeGemCapture(String gemCaptureId) async {
    final response = await api.delete(unlikeGemCapturePath(gemCaptureId));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error unliking the Gem Capture');
    }
  }
}
