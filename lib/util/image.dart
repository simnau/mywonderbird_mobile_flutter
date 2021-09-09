import 'dart:io';
import 'package:flutter_native_image/flutter_native_image.dart';

const double MAX_IMAGE_SIZE = 1920;

int getMaxWidth(double maxSize, double aspectRatio) {
  return (aspectRatio > 1 ? maxSize : maxSize * aspectRatio).floor();
}

int getMaxHeight(double maxSize, double aspectRatio) {
  return (aspectRatio > 1 ? maxSize / aspectRatio : maxSize).floor();
}

Future<List<int>> resizeImageAsBytes(filename) async {
  ImageProperties properties =
      await FlutterNativeImage.getImageProperties(filename);

  double aspectRatio = properties.width / properties.height;
  final maxWidth = getMaxWidth(MAX_IMAGE_SIZE, aspectRatio);
  final maxHeight = getMaxHeight(MAX_IMAGE_SIZE, aspectRatio);

  final resizedWidth =
      properties.width < maxWidth ? properties.width : maxWidth;
  final resizedHeight =
      properties.height < maxHeight ? properties.height : maxHeight;

  File compressedFile = await FlutterNativeImage.compressImage(
    filename,
    quality: 80,
    targetWidth: resizedWidth,
    targetHeight: resizedHeight,
  );

  return compressedFile.readAsBytes();
}
