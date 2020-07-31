import 'package:flutter/material.dart';
import 'package:layout/components/custom_icons.dart';
import 'package:layout/components/selection-list-item.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/journey.dart';
import 'package:layout/models/location.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/routes/home/main.dart';
import 'package:layout/routes/share-picture/select-journey.dart';
import 'package:layout/routes/share-picture/select-location.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/services/sharing.dart';
import 'package:layout/types/select-journey-arguments.dart';
import 'package:layout/types/select-location-arguments.dart';
import 'package:provider/provider.dart';

class SharingWidget extends StatefulWidget {
  final Journey selectedJourney;

  SharingWidget({this.selectedJourney});

  @override
  _SharingWidgetState createState() => _SharingWidgetState();
}

class _SharingWidgetState extends State<SharingWidget> {
  final _titleController = TextEditingController();

  Journey _selectedJourney;
  LocationModel _selectedLocation;
  String _error;
  bool _isSharing = false;

  Journey get journey => _selectedJourney ?? widget.selectedJourney;
  LocationModel get location {
    final sharePictureProvider = Provider.of<SharePictureProvider>(
      context,
      listen: false,
    );

    return _selectedLocation ?? sharePictureProvider.pictureData.location;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _image,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        bottom: 8.0,
                        top: 8.0,
                      ),
                      child: TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write a caption',
                          hintStyle: TextStyle(
                            color: Colors.black26,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        color: Colors.red,
                        child: Text(
                          _error,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    SelectionListItem(
                      icon: Icon(
                        CustomIcons.route,
                        color: journey != null
                            ? theme.primaryColor
                            : Colors.black87,
                        size: 40.0,
                      ),
                      changeTitle: 'Change the journey',
                      chooseTitle: 'Choose a journey',
                      item: journey,
                      onTap: _selectJourney,
                    ),
                    SelectionListItem(
                      icon: Icon(
                        Icons.location_on,
                        color: location != null
                            ? theme.primaryColor
                            : Colors.black87,
                        size: 40.0,
                      ),
                      changeTitle: 'Change the photo location',
                      chooseTitle: 'Choose the photo location',
                      item: location,
                      onTap: _selectLocation,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 32,
            left: 32,
            right: 32,
            child: RaisedButton(
              color: theme.primaryColor,
              textColor: Colors.white,
              child: _isSharing
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(),
                    )
                  : Text('Share'),
              onPressed: _isSharing ? null : _sharePicture,
            ),
          ),
        ],
      ),
    );
  }

  void _sharePicture() async {
    final sharingService = locator<SharingService>();
    final navigationService = locator<NavigationService>();
    final title = _titleController.text;
    final sharePictureProvider = Provider.of<SharePictureProvider>(
      context,
      listen: false,
    );

    try {
      setState(() {
        _isSharing = true;
      });

      await sharingService.sharePicture(
        title,
        sharePictureProvider.pictureData,
        _selectedLocation ?? sharePictureProvider.pictureData.location,
        journey.id,
      );

      navigationService.popUntil((route) => route.isFirst);
      navigationService.pushReplacementNamed(HomePage.PATH);
    } catch (e) {
      final snackBar = SnackBar(
        content: Text(
          e.toString(),
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      );

      Scaffold.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  void _selectJourney() async {
    final selectedJourney = await Navigator.pushNamed(
      context,
      SelectJourney.RELATIVE_PATH,
      arguments: SelectJourneyArguments(
        journey: journey,
      ),
    );

    if (selectedJourney != null) {
      setState(() {
        _selectedJourney = selectedJourney;
      });
    }
  }

  void _selectLocation() async {
    final selectedLocation = await Navigator.pushNamed(
      context,
      SelectLocation.RELATIVE_PATH,
      arguments: SelectLocationArguments(
        location: location,
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
      });
    }
  }

  ImageProvider get _image {
    final sharePictureProvider = Provider.of<SharePictureProvider>(
      context,
      listen: false,
    );

    return sharePictureProvider.pictureData.image;
  }
}
