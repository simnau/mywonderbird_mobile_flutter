import 'dart:async';

import 'package:layout/models/journey.dart';

final mockJourneys = [
  Journey(
    id: '1',
    name: 'A trek in Iceland',
    startDate: DateTime.now().subtract(
      Duration(
        hours: 2,
      ),
    ),
    imageUrl:
        'https://www.azamara.com/sites/default/files/heros/pr-6-aug-2020-akureyri-iceland.jpg',
  ),
  Journey(
    id: '2',
    name: 'Norway fjords',
    startDate: DateTime.now().subtract(
      Duration(
        days: 30,
      ),
    ),
    imageUrl:
        'https://www.scandinaviastandard.com/wp-content/uploads/2019/07/Norway-Fjords-Hardangerfjord-Trolltunga-the-Best-Fjords-to-Visit-in-Norway-Scandinavia-Standard-1.jpg',
  ),
  Journey(
    id: '3',
    name: 'Anyksciai day trip',
    startDate: DateTime.now().subtract(
      Duration(
        days: 180,
      ),
    ),
    imageUrl:
        'https://s2.15min.lt/images/photos/2018/04/28/original/anyksciu-silelio-medziu-laju-takas-5ae4850c5ace6.jpg',
  ),
];

class JourneyService {
  static Future<List<Journey>> allForUser() async {
    return Future.delayed(
      const Duration(seconds: 2),
      () => List.from(mockJourneys),
    );
  }

  static Future<Journey> createJourney(Journey journey) async {
    mockJourneys.insert(0, journey);
    return journey;
  }

  static Future<Journey> getLastJourney() async {
    return mockJourneys[0];
  }
}
