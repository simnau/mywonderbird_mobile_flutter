import 'dart:io';

import 'package:crop/crop.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/navigation.dart';

class CropImage extends StatelessWidget {
  final _controller = CropController(aspectRatio: 1 / 1);
  final File imagePath;

  CropImage({
    Key key,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => _onSelect(context),
            child: Text(
              'SELECT',
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ],
      ),
      body: Crop(
        child: Image.file(
          imagePath,
          fit: BoxFit.cover,
        ),
        controller: _controller,
        // shape: CropShape.oval,
      ),
    );
  }

  _onSelect(BuildContext context) async {
    final navigationService = locator<NavigationService>();

    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final croppedImage = await _controller.crop(pixelRatio: pixelRatio);

    navigationService.pop(croppedImage);
  }
}
