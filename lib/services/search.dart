import 'dart:io';

import 'package:mywonderbird/models/feed-location.dart';
import 'package:mywonderbird/services/api.dart';

const SEARCH_PLACES_PATH = '/api/search/places';

class SearchService {
  final API api;

  SearchService({
    this.api,
  });

  Future<List<FeedLocation>> searchPlaces({
    String query,
    List<String> types,
  }) async {
    final response = await api.post(SEARCH_PLACES_PATH, {
      'q': query,
      'types': types,
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('An error occurred'); // TODO handle properly
    }
    final places = response['body']['places'];

    return places.map<FeedLocation>((place) {
      return FeedLocation.fromJson(place);
    }).toList();
  }
}
