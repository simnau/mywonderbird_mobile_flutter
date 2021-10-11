import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/types/picture-share-data.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/util/image.dart';

import 'package:http/http.dart' as http;
import 'package:mywonderbird/util/json.dart';
import 'package:uuid/uuid.dart';

const SHARE_PICTURES_PATH = '/api/pictures/v2';

final Uuid uuid = Uuid();

class SharingService {
  final API api;

  SharingService({@required this.api});

  shareMultiplePictures(
    List<PictureShareData> pictures, {
    Journey trip,
  }) async {
    final List<http.MultipartFile> files = [];
    final pictureDatas = [];

    for (final picture in pictures) {
      final imageIds = [];

      for (final imagePath in picture.pictureData.imagePaths) {
        final imageId = uuid.v4();
        final filename = "$imageId.jpg";
        final fileBytes = await resizeImageAsBytes(imagePath);

        files.add(
          http.MultipartFile.fromBytes(
            imageId,
            fileBytes,
            filename: filename,
          ),
        );
        imageIds.add(imageId);
      }

      final pictureData = {
        ...picture.toStringJson(),
        'imageIds': imageIds,
      };

      pictureDatas.add(pictureData);
    }

    final fields = removeNulls({
      'pictureDatas': json.encode(pictureDatas),
      if (trip != null) ...{
        'journeyId': trip.id,
        'journeyTitle': trip.name,
      },
    });

    final response = await api.postMultipartFiles(
      SHARE_PICTURES_PATH,
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
