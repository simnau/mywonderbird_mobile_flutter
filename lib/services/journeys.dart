import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:layout/models/journey.dart';

final apiBase = DotEnv().env['API_BASE'];
final createJourneyUrl = "$apiBase/api/journeys";
final myJourneysUrl = "$apiBase/api/journeys/my";
final lastJourneyUrl = "$apiBase/api/journeys/last";

class JourneyService {
  static Future<List<Journey>> allForUser() async {
    final response = await http.get(myJourneysUrl);
    final journeysRaw = json.decode(response.body)['journeys'];

    final journeys = journeysRaw
        .map<Journey>((journey) => Journey.fromRequestJson(journey))
        .toList();

    return journeys;
  }

  static Future<Journey> createJourney(Journey journey) async {
    final response = await http.post(
      createJourneyUrl,
      body: json.encode(journey.toJson()),
      headers: {
        'content-type': 'application/json',
      },
    );
    final journeyRaw = json.decode(response.body);
    final savedJourney = Journey.fromRequestJson(journeyRaw);

    return savedJourney;
  }

  static Future<Journey> getLastJourney() async {
    final response = await http.get(lastJourneyUrl);
    final journeyRaw = json.decode(response.body)['journey'];
    final journey = Journey.fromRequestJson(journeyRaw);

    return journey;
  }
}
