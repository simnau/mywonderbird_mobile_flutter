import 'dart:async';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:layout/models/location.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/routes/share-picture/select-destination.dart';
import 'package:layout/services/location.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/types/picture-data.dart';
import 'package:layout/util/geo.dart';
import 'package:layout/util/location.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'locator.dart';

class SharingIntent {
  StreamSubscription _intentDataStreamSubscription;

  setupSharingIntentListeners() {
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

  dispose() {
    _intentDataStreamSubscription.cancel();
  }

  _handleShare(String filePath) async {
    final locationService = locator<LocationService>();
    final file = File(filePath);
    final fileBytes = await file.readAsBytes();
    final data = await readExifFromBytes(fileBytes);

    final creationDate = await file.lastModified();
    final latitudeRef = data['GPS GPSLatitudeRef']?.toString();
    final latitudeRatios = data['GPS GPSLatitude']?.values;
    final longitudeRef = data['GPS GPSLongitudeRef']?.toString();
    final longitudeRatios = data['GPS GPSLongitude']?.values;

    double latitude;
    double longitude;

    if (latitudeRatios != null || longitudeRatios != null) {
      latitude = dmsRatioToDouble(latitudeRatios);
      latitude = isNegativeRef(latitudeRef) ? -latitude : latitude;
      longitude = dmsRatioToDouble(longitudeRatios);
      longitude = isNegativeRef(longitudeRef) ? -longitude : longitude;
    }

    if ((latitude == null || latitude.isNaN) &&
        (longitude == null || longitude.isNaN)) {
      final currentLocation = await getCurrentLocation();
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
    }

    final sharePictureProvider = locator<SharePictureProvider>();
    final latLng = LatLng(latitude, longitude);
    final locationModel = await locationService.reverseGeocode(latLng);

    sharePictureProvider.pictureData = PictureData(
      image: FileImage(File(filePath)),
      imagePath: filePath,
      location: LocationModel(
        id: locationModel?.id,
        latLng: LatLng(latitude, longitude),
        country: locationModel?.country,
        countryCode: locationModel?.countryCode,
        name: locationModel?.name ?? latLngToString(latLng),
        imageUrl: filePath,
        provider: locationModel?.provider,
      ),
      creationDate: creationDate,
    );

    locator<NavigationService>().pushReplacementNamed(SelectDestination.PATH);
  }
}
