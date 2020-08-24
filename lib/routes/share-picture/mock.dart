import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/location.dart';

const MOCK_IMAGE =
    'https://www.icelandreview.com/wp-content/uploads/2019/08/img_2324.jpg';
const MOCK_IMAGE_2 =
    'https://i.pinimg.com/736x/47/e5/82/47e582b99757e1485bd2f11a0f602c5f.jpg';
const MOCK_IMAGE_3 =
    'https://media.audleytravel.com/-/media/images/home/europe/iceland/places-to-visit/lake_myvatn_istock_1096159972_letterbox.jpg?q=79&w=1920&h=640';
const MOCK_IMAGE_4 =
    'https://www.followmeaway.com/wp-content/uploads/2018/01/gullfoss-waterfall-Iceland-green-traditional-view-1280x533.jpg';
const MOCK_IMAGE_LAT_LNG = LatLng(64.128288, -21.827774);
const MOCK_LOCATION = LocationModel(
  id: 'Just a key',
  country: 'Iceland',
  countryCode: 'ISL',
  imageUrl: MOCK_IMAGE,
  latLng: MOCK_IMAGE_LAT_LNG,
  name: 'Reykjavik',
);
