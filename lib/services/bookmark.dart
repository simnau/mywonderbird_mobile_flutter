import 'dart:io';

import 'package:layout/models/bookmarked-location.dart';
import 'package:layout/services/api.dart';

const BOOKMARK_GEM_CAPTURE_PATH = '/api/bookmarks/gem-captures';
const GET_BOOKMARKED_GEM_CAPTURES_PATH = BOOKMARK_GEM_CAPTURE_PATH;
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

  Future<List<BookmarkedLocationModel>> fetchBookmarkedGemCaptures(
    page,
    pageSize,
  ) async {
    final response = await api.get(GET_BOOKMARKED_GEM_CAPTURES_PATH, params: {
      'page': page?.toString(),
      'pageSize': pageSize?.toString(),
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error fetching bookmarked Gem Captures');
    }
    final bookmarks = response['body']['bookmarks'];

    return bookmarks.map<BookmarkedLocationModel>((bookmark) {
      return BookmarkedLocationModel.fromResponseJson(bookmark);
    }).toList();
  }
}
