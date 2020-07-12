import 'package:flutter/material.dart';
import 'package:layout/components/custom_icons.dart';
import 'package:layout/components/selection-list-item.dart';
import 'package:layout/locator.dart';
import 'package:layout/models/journey.dart';
import 'package:layout/models/location.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/routes/home.dart';
import 'package:layout/routes/share-picture/select-journey.dart';
import 'package:layout/routes/share-picture/select-location.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/services/sharing.dart';
import 'package:layout/types/select-journey-arguments.dart';
import 'package:layout/types/select-location-arguments.dart';
import 'package:provider/provider.dart';

class ShareScreen extends StatefulWidget {
  static const RELATIVE_PATH = 'share-picture/share';
  static const PATH = "/$RELATIVE_PATH";

  final Journey selectedJourney;

  ShareScreen({this.selectedJourney});

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _titleController = TextEditingController();

  Journey _selectedJourney;
  LocationModel _selectedLocation;
  String _error;

  Journey get journey => _selectedJourney ?? widget.selectedJourney;
  LocationModel get location {
    final sharePictureProvider = Provider.of<SharePictureProvider>(
      context,
      listen: false,
    );

    return _selectedLocation ?? sharePictureProvider.pictureData.location;
  }

  ImageProvider get image {
    final sharePictureProvider = Provider.of<SharePictureProvider>(
      context,
      listen: false,
    );

    return sharePictureProvider.pictureData.image;
  }

  void _cancel(BuildContext context) {
    Navigator.of(context, rootNavigator: true).popUntil(
      (route) => route.settings.name == Home.PATH,
    );
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

  void _sharePicture() async {
    final sharingService = locator<SharingService>();
    final navigationService = locator<NavigationService>();
    final title = _titleController.text;
    final sharePictureProvider = Provider.of<SharePictureProvider>(
      context,
      listen: false,
    );

    try {
      await sharingService.sharePicture(
        title,
        sharePictureProvider.pictureData,
        journey.id,
      );

      navigationService.popUntil((route) => route.isFirst);
      navigationService.pushReplacementNamed(Home.PATH);
    } catch (e) {
      _error = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: () => _cancel(context),
          )
        ],
      ),
      body: Container(
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
                        image: image,
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
                child: Text(
                  'Share',
                ),
                onPressed: _sharePicture,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
