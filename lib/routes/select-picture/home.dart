import 'package:flutter/material.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/routes/home/main.dart';
import 'package:layout/routes/share-picture/mock.dart';
import 'package:layout/routes/share-picture/select-destination.dart';
import 'package:layout/types/picture-data.dart';
import 'package:provider/provider.dart';

class SelectPictureHome extends StatefulWidget {
  static const RELATIVE_PATH = 'select-picture';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _SelectPictureHomeState createState() => _SelectPictureHomeState();
}

class _SelectPictureHomeState extends State<SelectPictureHome> {
  @override
  void initState() {
    super.initState();

    final sharePictureProvider = Provider.of<SharePictureProvider>(
      context,
      listen: false,
    );

    sharePictureProvider.pictureData = PictureData(
      image: NetworkImage(MOCK_IMAGE),
      imagePath: '',
      location: MOCK_LOCATION,
      creationDate: DateTime.now(),
    );
  }

  void _onBack() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop();
  }

  void _cancel() {
    Navigator.of(context, rootNavigator: true).popUntil(
      (route) => route.settings.name == HomePage.PATH,
    );
  }

  void _onNext() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed(SelectDestination.PATH);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: _onBack,
        ),
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: _cancel,
          )
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 32,
              left: 32,
              right: 32,
              child: RaisedButton(
                color: theme.primaryColor,
                textColor: Colors.white,
                child: Text(
                  'Next',
                ),
                onPressed: _onNext,
              ),
            )
          ],
        ),
      ),
    );
  }
}
