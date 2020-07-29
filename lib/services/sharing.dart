import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:layout/models/location.dart';
import 'package:layout/services/api.dart';
import 'package:layout/util/image.dart';

import 'package:http/http.dart' as http;
import 'package:layout/types/picture-data.dart';
import 'package:uuid/uuid.dart';

final sharePicturePath = (journeyId) => "/api/pictures/$journeyId";
final uploadPicturePath = (journeyId) => "/api/pictures/$journeyId/file";

class SharingService {
  final API api;

  SharingService({@required this.api});

  Future<String> _uploadPicture(
    PictureData pictureData,
    String journeyId,
  ) async {
    final requestPath = uploadPicturePath(journeyId);
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

    final response = await api.postMultipartFiles(requestPath, files);
    final body = response['body'];
    final imagePath = body['images'][0];

    return imagePath;
  }

  sharePicture(
    String title,
    PictureData pictureData,
    LocationModel locationModel,
    String journeyId,
  ) async {
    final imageUrl = await _uploadPicture(pictureData, journeyId);
    final pictureDataJson = pictureData.toJson();
    final locationJson = locationModel?.toJson();

    // TODO: handle in case of errors!
    await api.post(
      sharePicturePath(journeyId),
      {
        'imageUrl': imageUrl,
        'title': title,
        'creationDate': pictureDataJson['creationDate'],
        'location': locationJson,
      },
    );
  }
}
