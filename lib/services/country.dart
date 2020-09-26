import 'dart:io';

import 'package:mywonderbird/models/label-value-pair.dart';
import 'package:mywonderbird/services/api.dart';

const SEARCH_COUNTRIES_PATH = '/api/geo/countries/search';

class CountryService {
  final API api;

  CountryService({
    this.api,
  });

  Future<List<LabelValuePair>> searchCountries(String query) async {
    final response = await api.get(SEARCH_COUNTRIES_PATH, params: {
      'q': query,
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error fetching bookmarked Gem Captures');
    }
    final countries = response['body'];

    return countries.map<LabelValuePair>((country) {
      return LabelValuePair.fromJson(country);
    }).toList();
  }
}
