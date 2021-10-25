import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/picture-data.dart';

import '../select-picture/main.dart';
import '../share-pictures-trip/main.dart';
import '../share-pictures-standalone/main.dart';
import '../../components/big-action-button.dart';

class SelectUploadType extends StatelessWidget {
  final List<String> imagePaths;

  const SelectUploadType({
    Key key,
    this.imagePaths,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Subtitle1('Share your adventure'),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(spacingFactor(2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BigActionButton(
            onTap: _onCreateTrip,
            variant: BigActionButtonVariant.primary,
            icon: MaterialCommunityIcons.map_marker_path,
            title: 'Create a trip from photos',
            subtitle:
                'Create a trip from photos of your experiences and share it for everyone to see',
          ),
          SizedBox(height: spacingFactor(3)),
          BigActionButton(
            onTap: _onSingleLocation,
            icon: Icons.add_photo_alternate_outlined,
            title: 'Share photos of a spot',
            subtitle: 'Share photos of a single spot that you visited',
          ),
        ],
      ),
    );
  }

  _onCreateTrip() async {
    final navigationService = locator<NavigationService>();

    if (imagePaths != null && imagePaths.isNotEmpty) {
      final pictureDataService = locator<PictureDataService>();

      final pictureDatas = await pictureDataService.extractPicturesData(
        imagePaths,
        false,
      );

      navigationService.push(
        MaterialPageRoute(
          builder: (_) => SharePicturesTrip(pictureDatas: pictureDatas),
        ),
      );
    } else {
      navigationService.push(MaterialPageRoute(
        builder: (context) => SelectPicture(isStandalone: false),
      ));
    }
  }

  _onSingleLocation() async {
    final navigationService = locator<NavigationService>();

    if (imagePaths != null && imagePaths.isNotEmpty) {
      final pictureDataService = locator<PictureDataService>();

      final pictureDatas = await pictureDataService.extractPicturesData(
        imagePaths,
        true,
      );

      navigationService.push(
        MaterialPageRoute(
          builder: (_) => SharePicturesStandalone(pictureDatas: pictureDatas),
        ),
      );
    } else {
      navigationService.push(MaterialPageRoute(
        builder: (context) => SelectPicture(isStandalone: true),
      ));
    }
  }
}
