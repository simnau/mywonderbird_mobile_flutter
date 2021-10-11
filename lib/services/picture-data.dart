import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/services/geo.dart';
import 'package:mywonderbird/types/picture-data.dart';
import 'package:mywonderbird/util/geo.dart';

class PictureDataService {
  final GeoService locationService;

  PictureDataService({this.locationService});

  Future<PictureData> extractPictureData(String filePath) async {
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

    var location;

    if (latitude != null && longitude != null) {
      final latLng = LatLng(latitude, longitude);
      final locationModel = await locationService.reverseGeocode(latLng);

      location = LocationModel(
        id: locationModel?.id,
        latLng: LatLng(latitude, longitude),
        country: locationModel?.country,
        countryCode: locationModel?.countryCode,
        name: locationModel?.name,
        imageUrl: filePath,
        provider: locationModel?.provider,
      );
    }

    return PictureData(
      images: [FileImage(File(filePath))],
      imagePaths: [filePath],
      location: location,
      creationDate: creationDate,
    );
  }

  Future<List<PictureData>> extractPicturesData(
    List<String> filePaths,
    bool isSingle,
  ) async {
    final files = filePaths.map<File>((filePath) => File(filePath)).toList();
    final exifDatas = await Future.wait(
      files
          .map<Future<Map<String, IfdTag>>>(
              (file) async => await readExifFromFile(file))
          .toList(),
    );
    final locations =
        exifDatas.map((exifData) => extractLocation(exifData)).toList();

    final locationModels = await locationService.multiReverseGeocode(locations);
    final creationDates = await Future.wait(
      files.map<Future<DateTime>>((file) => file.lastModified()).toList(),
    );

    final List<PictureData> pictureDatas = [];

    if (isSingle) {
      final List<ImageProvider<Object>> images = [];
      final List<String> imagePaths = [];
      final creationDate = creationDates[0];
      var location;

      for (var index = 0; index < locationModels.length; index++) {
        final locationModel = locationModels[index];

        if (location == null &&
            locationModel != null &&
            locationModel.latLng != null) {
          location = locationModel;
        }
        final file = files[index];

        images.add(FileImage(file));
        imagePaths.add(file.path);
      }

      pictureDatas.add(
        PictureData(
          images: images,
          imagePaths: imagePaths,
          location: location,
          creationDate: creationDate,
        ),
      );

      return pictureDatas;
    } else {
      for (var index = 0; index < locationModels.length; index++) {
        final creationDate = creationDates[index];
        final location = locationModels[index];
        final file = files[index];

        final pictureData = PictureData(
          images: [FileImage(file)],
          imagePaths: [file.path],
          location: location,
          creationDate: creationDate,
        );

        pictureDatas.add(pictureData);
      }

      return sortByCreationDate(pictureDatas);
    }
  }

  LatLng extractLocation(Map<String, IfdTag> exifData) {
    final latitudeRef = exifData['GPS GPSLatitudeRef']?.toString();
    final latitudeRatios = exifData['GPS GPSLatitude']?.values;
    final longitudeRef = exifData['GPS GPSLongitudeRef']?.toString();
    final longitudeRatios = exifData['GPS GPSLongitude']?.values;

    double latitude;
    double longitude;

    if (latitudeRatios != null || longitudeRatios != null) {
      latitude = dmsRatioToDouble(latitudeRatios);
      latitude = isNegativeRef(latitudeRef) ? -latitude : latitude;
      longitude = dmsRatioToDouble(longitudeRatios);
      longitude = isNegativeRef(longitudeRef) ? -longitude : longitude;
    }

    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }

    return null;
  }

  List<PictureData> sortByCreationDate(List<PictureData> pictureDatas) {
    final pictureDataCopy = [...pictureDatas];

    pictureDataCopy.sort((pictureData1, pictureData2) {
      return pictureData1.creationDate.compareTo(pictureData2.creationDate);
    });

    return pictureDataCopy;
  }
}
