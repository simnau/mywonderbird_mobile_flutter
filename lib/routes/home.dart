import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:layout/components/bottom-nav-bar.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/location.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/routes/select-picture/home.dart';
import 'package:layout/routes/share-picture/select-destination.dart';
import 'package:layout/services/location.dart';
import 'package:layout/types/picture-data.dart';
import 'package:layout/util/geo.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class Home extends StatefulWidget {
  static const PATH = '/';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value == null) {
        return;
      }

      for (var image in value) {
        _handleShare(image.path);
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value == null) {
        return;
      }

      for (var image in value) {
        _handleShare(image.path);
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text('Home'),
      ),
      floatingActionButton: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(2.0),
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 36,
          ),
          onPressed: () {
            Navigator.pushNamed(context, SelectPictureHome.PATH);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(),
    );
  }

  void _handleShare(String filePath) async {
    final locationService = locator<LocationService>();
    File file = File(filePath);
    Uint8List fileBytes = await file.readAsBytes();
    Map<String, IfdTag> data = await readExifFromBytes(fileBytes);

    final creationDate = await file.lastModified();
    final latitudeRef = data['GPS GPSLatitudeRef']?.toString();
    final latitudeRatios = data['GPS GPSLatitude'].values;
    final longitudeRef = data['GPS GPSLongitudeRef']?.toString();
    final longitudeRatios = data['GPS GPSLongitude'].values;

    var latitude = dmsRatioToDouble(latitudeRatios);
    latitude = isNegativeRef(latitudeRef) ? -latitude : latitude;
    var longitude = dmsRatioToDouble(longitudeRatios);
    longitude = isNegativeRef(longitudeRef) ? -longitude : longitude;

    final sharePictureProvider = Provider.of<SharePictureProvider>(
      context,
      listen: false,
    );
    final latlng = LatLng(latitude, longitude);
    final locationModel = await locationService.reverseGeocode(latlng);

    sharePictureProvider.pictureData = PictureData(
      image: FileImage(File(filePath)),
      imagePath: filePath,
      location: LocationModel(
        id: locationModel.id,
        latLng: LatLng(latitude, longitude),
        country: locationModel.country,
        countryCode: locationModel.countryCode,
        name: locationModel.name,
        imageUrl: filePath,
        provider: locationModel.provider,
      ),
      creationDate: creationDate,
    );

    Navigator.pushNamed(
      context,
      SelectDestination.PATH,
    );
  }
}
