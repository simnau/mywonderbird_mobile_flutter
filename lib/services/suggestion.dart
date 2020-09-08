import 'package:mywonderbird/models/full-journey.dart';
import 'package:mywonderbird/services/api.dart';

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
}
