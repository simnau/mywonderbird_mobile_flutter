import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/models/suggested-journey.dart';
import 'package:mywonderbird/models/suggested-location.dart';
import 'package:mywonderbird/services/api.dart';

const SUGGESTED_LOCATIONS_PATH = '/api/suggestions/locations';
const SUGGEST_LOCATIONS_PAGINATED_PATH = '/api/suggestions/locations/paginated';
const SUGGEST_JOURNEY_FROM_LOCATIONS_PATH = '/api/suggestions/locations';
const SUGGEST_JOURNEY_FROM_LOCATIONS_STARTING_AT_PATH =
    '/api/suggestions/locations/from-point';
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
    List<String> locationIds, {
    lng: double,
    lat: double,
  }) async {
    final response = await api.post(SUGGEST_JOURNEY_FROM_LOCATIONS_PATH, {
      'locationIds': locationIds,
      'startingLocation': lng != null && lat != null
          ? {
              'lng': lng,
              'lat': lat,
            }
          : null,
    });
    final journeyRaw = response['body']['journey'];
    final journey = SuggestedJourney.fromJson(journeyRaw);

    return journey;
  }

  Future<SuggestedJourney> suggestJourneyFromLocationsStartingAt(
    List<String> locationIds,
    String startingLocationId,
  ) async {
    final response =
        await api.post(SUGGEST_JOURNEY_FROM_LOCATIONS_STARTING_AT_PATH, {
      'locationIds': locationIds,
      'startingLocationId': startingLocationId,
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
    List<SuggestedLocation> selectedLocations,
  }) async {
    Map<String, dynamic> params = {
      "page": page?.toString(),
      "pageSize": pageSize?.toString(),
      "tags": tags,
      "latMin": southWest?.latitude?.toString(),
      "latMax": northEast?.latitude?.toString(),
      "lngMin": southWest?.longitude?.toString(),
      "lngMax": northEast?.longitude?.toString(),
      "selectedLocations": selectedLocations?.map((e) => e.id) ?? [],
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
