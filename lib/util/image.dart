import 'dart:io';

import 'package:image/image.dart';

const double MAX_IMAGE_SIZE = 1080;

int _getMaxWidth(double maxSize, double aspectRatio) {
  return (aspectRatio > 1 ? maxSize : maxSize * aspectRatio).floor();
}

int _getMaxHeight(double maxSize, double aspectRatio) {
  return (aspectRatio > 1 ? maxSize / aspectRatio : maxSize).floor();
}

Future<List<int>> resizeImageAsBytes(filename) async {
  final image = decodeJpg(await File(filename).readAsBytes());
  double aspectRatio = image.width / image.height;
  final maxWidth = _getMaxWidth(MAX_IMAGE_SIZE, aspectRatio);
  final maxHeight = _getMaxHeight(MAX_IMAGE_SIZE, aspectRatio);

  final resizedWidth = image.width < maxWidth ? image.width : maxWidth;
  final resizedHeight = image.height < maxHeight ? image.height : maxHeight;

  Image resizedImage = copyResize(
    image,
    width: resizedWidth,
    height: resizedHeight,
  );

  return encodeJpg(resizedImage, quality: 80);
}
