import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:layout/models/location.dart';

const List<Location> MOCK_LOCATIONS = [
  Location(
    id: '1',
    name: 'Kedainiai',
    country: 'Lithuania',
    imageUrl:
        'https://welovelithuania.com/content/uploads/2018/12/Diana-Garba%C4%8Dauskien%C4%97-KEDAINIAI-WLL-e1545308046814.jpg',
    latLng: const LatLng(55.227986, 23.937895),
  ),
  Location(
    id: '2',
    name: 'Kaunas',
    country: 'Lithuania',
    imageUrl: 'https://medusaconcert.lt/wp-content/uploads/Kaunas.jpg',
    latLng: const LatLng(54.897260, 23.884347),
  ),
  Location(
    id: '3',
    name: 'Vilnius',
    country: 'Lithuania',
    imageUrl:
        'https://www.govilnius.lt/api/images/5e513a5f66c3a8656713e6b6?w=1440&h=605',
    latLng: const LatLng(54.686201, 25.278372),
  ),
];

class LocationService {
  static Future<List<Location>> searchLocations(String query) async {
    final List<Location> locations = MOCK_LOCATIONS
        .where((element) =>
            element.name.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return Future.delayed(
      Duration(seconds: 2),
      () => locations,
    );
  }
}
