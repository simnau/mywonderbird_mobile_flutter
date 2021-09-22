import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/routes/home/main.dart';
import 'package:mywonderbird/routes/picture-sharing/components/sharing-widget.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/select-location/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/sharing.dart';
import 'package:mywonderbird/util/snackbar.dart';

class SharePictureSingleScreen extends StatefulWidget {
  const SharePictureSingleScreen({Key key}) : super(key: key);

  @override
  _SharePictureSingleScreenState createState() =>
      _SharePictureSingleScreenState();
}

class _SharePictureSingleScreenState extends State<SharePictureSingleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  LocationModel _selectedLocation;
  bool _isSharing = false;

  LocationModel get location {
    final sharePictureProvider = locator<SharePictureProvider>();

    return _selectedLocation ?? sharePictureProvider.pictureData.location;
  }

  ImageProvider get image {
    final sharePictureProvider = locator<SharePictureProvider>();

    return sharePictureProvider.pictureData.image;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: _isSharing ? null : () => _sharePicture(context),
                child: _isSharing
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(),
                      )
                    : Text(
                        'SHARE',
                        style: TextStyle(color: theme.primaryColor),
                      ),
              );
            },
          ),
        ],
      ),
      body: _content(),
    );
  }

  Widget _content() {
    return SharingWidget(
      onSelectLocation: _onSelectLocation,
      onLocationChange: _onLocationChange,
      location: location,
      image: image,
      formKey: _formKey,
      titleController: _titleController,
      descriptionController: _descriptionController,
      single: true,
    );
  }

  _sharePicture(BuildContext context) async {
    final sharingService = locator<SharingService>();
    final navigationService = locator<NavigationService>();
    final sharePictureProvider = locator<SharePictureProvider>();

    if (!_formKey.currentState.validate()) {
      return;
    }

    try {
      setState(() {
        _isSharing = true;
      });

      await sharingService.shareSinglePicture(
        _titleController.text,
        _descriptionController.text,
        sharePictureProvider.pictureData,
        _selectedLocation ?? sharePictureProvider.pictureData.location,
      );

      navigationService.popUntil((route) => route.isFirst);
      navigationService.pushReplacementNamed(HomePage.PATH);
    } catch (e) {
      final snackBar = createErrorSnackbar(text: e.toString());
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  Future<LocationModel> _onSelectLocation() async {
    final navigationService = locator<NavigationService>();
    final selectedLocation = await navigationService.push(
      MaterialPageRoute(
        builder: (context) => SelectLocation(
          location: location,
        ),
      ),
    );

    if (selectedLocation != null) {
      return selectedLocation;
    }

    return null;
  }

  _onLocationChange(LocationModel location) {
    setState(() {
      _selectedLocation = location;
    });
  }
}
