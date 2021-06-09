import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/util/date.dart';
import 'package:mywonderbird/util/image.dart';

import 'package:http/http.dart' as http;
import 'package:mywonderbird/types/picture-data.dart';
import 'package:mywonderbird/util/json.dart';
import 'package:uuid/uuid.dart';

const SHARE_PICTURE_PATH = '/api/pictures';
final sharePicturePath = (journeyId) => "/api/pictures/$journeyId";
final uploadPicturePath = (journeyId) => "/api/pictures/$journeyId/file";

class SharingService {
  final API api;

  SharingService({@required this.api});

  sharePicture(
    String title,
    String description,
    PictureData pictureData,
    LocationModel locationModel,
    Journey journey,
  ) async {
    final filename = "${Uuid().v4()}.jpg";
    final fileBytes = await compute<String, List<int>>(
      resizeImageAsBytes,
      pictureData.imagePath,
    );
    final files = [
      http.MultipartFile.fromBytes(
        filename,
        fileBytes,
        filename: filename,
      ),
    ];
    final fields = removeNulls({
      'title': title,
      'description': description,
      'creationDate': formatDateTime(pictureData.creationDate),
      'journeyId': journey.id,
      'journeyTitle': journey.name,
      ...locationModel.toStringJson(),
    });

    final response = await api.postMultipartFiles(
      SHARE_PICTURE_PATH,
      files,
      fields: fields,
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        'There was an error sharing the picture. Please try again later',
      );
    }

    return response;
  }
}
