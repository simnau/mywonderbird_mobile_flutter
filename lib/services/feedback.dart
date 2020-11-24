import 'dart:io';

import 'package:mywonderbird/services/api.dart';

const FEEDBACK_PATH = '/api/feedback';

class FeedbackService {
  final API api;

  FeedbackService({this.api});

  submit(
      String whatYouLike, String improvements, String newFunctionality) async {
    final response = await api.post(FEEDBACK_PATH, {
      'whatYouLike': whatYouLike,
      'improvements': improvements,
      'newFunctionality': newFunctionality,
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error submitting feedback');
    }
  }
}
