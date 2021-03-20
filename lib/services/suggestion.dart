import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/suggested-journey.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/services/api.dart';

const SUGGESTED_LOCATIONS_PATH = '/api/suggestions/locations';
const SUGGEST_LOCATIONS_PAGINATED_PATH = '/api/suggestions/locations/paginated';
const SUGGEST_JOURNEY_FROM_LOCATIONS_PATH = '/api/suggestions/locations';
final suggestJourneyPath =
    (bookmarkGroupId) => "/api/suggestions/$bookmarkGroupId";

class SuggestionService {
  final API api;

  SuggestionService({
    this.api,
  });

  Future<FullJourney> suggestJourney(String bookmarkGroupId) async {
    final response = await api.get(suggestJourneyPath(bookmarkGroupId));
    final journeyRaw = response['body']['journey'];
    final journey = FullJourney.fromJson(journeyRaw);

    return journey;
  }

  Future<SuggestedJourney> suggestJourneyFromLocations(
      List<String> locationIds) async {
    final response = await api.post(SUGGEST_JOURNEY_FROM_LOCATIONS_PATH, {
      'locationIds': locationIds,
    });
    final journeyRaw = response['body']['journey'];
    final journey = SuggestedJourney.fromJson(journeyRaw);

    return journey;
  }

  Future<List<SuggestedLocation>> suggestedLocations(
    Map<String, String> questionnaireValues,
  ) async {
    questionnaireValues["countryCode"] = "Lt";
    questionnaireValues["country"] = "LTU";

    final response =
        await api.get(SUGGESTED_LOCATIONS_PATH, params: questionnaireValues);
    final suggestionsRaw = response['body']['locations'];
    final suggestions = suggestionsRaw
        .map<SuggestedLocation>(
            (suggestion) => SuggestedLocation.fromJson(suggestion))
        .toList();

    return suggestions;
  }

  Future<List<SuggestedLocation>> suggestLocations({
    int page,
    int pageSize,
    List<String> tags = const [],
    LatLng southWest,
    LatLng northEast,
  }) async {
    Map<String, dynamic> params = {
      "page": page?.toString(),
      "pageSize": pageSize?.toString(),
      "tags": tags,
      "latMin": southWest?.latitude?.toString(),
      "latMax": northEast?.latitude?.toString(),
      "lngMin": southWest?.longitude?.toString(),
      "lngMax": northEast?.longitude?.toString(),
    };
    final response =
        await api.get(SUGGEST_LOCATIONS_PAGINATED_PATH, params: params);

    final suggestionsRaw = response['body']['locations'];
    final suggestions = suggestionsRaw
        .map<SuggestedLocation>(
            (suggestion) => SuggestedLocation.fromJson(suggestion))
        .toList();

    return suggestions;
  }
}
