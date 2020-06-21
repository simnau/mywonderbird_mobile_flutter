import 'dart:convert';

import 'package:layout/util/image.dart';
import 'package:path/path.dart' as path;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:layout/types/picture-data.dart';
import 'package:uuid/uuid.dart';

final apiBase = DotEnv().env['API_BASE'];
final sharePictureUrl = (journeyId) => "$apiBase/api/pictures/$journeyId";
final uploadPictureUrl = (journeyId) => "$apiBase/api/pictures/$journeyId/file";

class SharingService {
  static Future<String> _uploadPicture(
    PictureData pictureData,
    String journeyId,
  ) async {
    final uri = uploadPictureUrl(journeyId);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(uri),
    );

    final fileExtension = path.extension(pictureData.imagePath);
    final filename = "${Uuid().v4()}$fileExtension";
    final fileBytes = resizeImageAsBytes(pictureData.imagePath);
    request.files.add(
      http.MultipartFile.fromBytes(
        filename,
        fileBytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = json.decode(response.body);
    final imagePath = body['images'][0];

    return imagePath;
  }

  static Future<void> sharePicture(
      String title, PictureData pictureData, String journeyId) async {
    // final imageUrl = await _uploadPicture(pictureData, journeyId);
    final imageUrl =
        'https://mywonderbird-images-dev.s3.eu-central-1.amazonaws.com/74c7d9f0-06a3-4c64-af6e-e639c2293c01/d4786513-f980-40a8-82c7-fd2a1d207045.png';
    final pictureDataJson = pictureData.toJson();

    await http.post(
      sharePictureUrl(journeyId),
      body: json.encode({
        'imageUrl': imageUrl,
        'title': title,
        'creationDate': pictureDataJson['creationDate'],
        'location': pictureDataJson['location'],
      }),
      headers: {
        'content-type': 'application/json',
      },
    );
  }
}
