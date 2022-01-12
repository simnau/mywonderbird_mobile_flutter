import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/picture-data.dart';
import 'package:mywonderbird/types/picture-data.dart';
import 'package:mywonderbird/util/snackbar.dart';

import '../share-pictures-trip/main.dart';
import '../share-pictures-standalone/main.dart';
import '../../components/big-action-button.dart';

class SelectUploadType extends StatefulWidget {
  final List<String> imagePaths;

  const SelectUploadType({
    Key key,
    this.imagePaths,
  }) : super(key: key);

  @override
  State<SelectUploadType> createState() => _SelectUploadTypeState();
}

class _SelectUploadTypeState extends State<SelectUploadType> {
  bool _isLoading = false;

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
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

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
    _onSelectType(false);
  }

  _onSingleLocation() async {
    _onSelectType(true);
  }

  _onSelectType(bool isSingle) async {
    final navigationService = locator<NavigationService>();
    final pictureDataService = locator<PictureDataService>();
    List<PictureData> pictureDatas;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.imagePaths != null && widget.imagePaths.isNotEmpty) {
        pictureDatas = await pictureDataService.extractPicturesData(
          widget.imagePaths,
          isSingle,
        );
      } else {
        final images = await ImagePicker().pickMultiImage();
        final paths = images?.map((image) => image.path)?.toList();

        pictureDatas = await pictureDataService.extractPicturesData(
          paths,
          isSingle,
        );
      }

      if (pictureDatas != null) {
        navigationService.push(
          MaterialPageRoute(
            builder: (_) => isSingle
                ? SharePicturesStandalone(pictureDatas: pictureDatas)
                : SharePicturesTrip(pictureDatas: pictureDatas),
          ),
        );
      }
    } catch (e) {
      final snackBar = createErrorSnackbar(
        text: "There was an error selecting pictures. Please try again",
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
