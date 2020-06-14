import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:layout/models/location.dart';

const MOCK_IMAGE =
    'https://www.azamara.com/sites/default/files/heros/reykjavik-iceland-1800x1000.jpg';
const MOCK_IMAGE_LAT_LNG = LatLng(64.128288, -21.827774);
const MOCK_LOCATION = Location(
  id: 'Just a key',
  country: 'Iceland',
  imageUrl: MOCK_IMAGE,
  latLng: MOCK_IMAGE_LAT_LNG,
  name: 'Reykjavik',
);
