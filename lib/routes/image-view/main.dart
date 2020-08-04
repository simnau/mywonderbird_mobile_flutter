import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/services/navigation.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  final ImageProvider image;

  const ImageView({
    Key key,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            color: Colors.white,
            onPressed: _onBack,
          )
        ],
      ),
      body: Container(
        child: PhotoView(
          imageProvider: image,
        ),
      ),
    );
  }

  _onBack() {
    final navigationService = locator<NavigationService>();
    navigationService.pop();
  }
}
