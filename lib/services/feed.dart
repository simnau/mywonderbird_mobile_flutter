import 'dart:io';

import 'package:mywonderbird/models/feed-location.dart';
import 'package:mywonderbird/services/api.dart';

const FETCH_FEED_ITEMS_PATH = '/api/pictures/feed';

class FeedService {
  final API api;

  FeedService({this.api});

  Future<List<FeedLocation>> fetchFeedItems(DateTime lastDatetime) async {
    final formattedtLastDateTime = lastDatetime?.toUtc()?.toIso8601String();

    final response = await api.get(
      FETCH_FEED_ITEMS_PATH,
      params: {
        'lastDatetime': formattedtLastDateTime,
      },
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('An error occurred'); // TODO handle properly
    }
    final feedItems = response['body']['feedItems'];

    return feedItems.map<FeedLocation>((feedItem) {
      return FeedLocation.fromJson(feedItem);
    }).toList();
  }
}
