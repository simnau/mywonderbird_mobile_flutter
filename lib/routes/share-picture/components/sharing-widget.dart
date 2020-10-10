import 'package:flutter/material.dart';
import 'package:mywonderbird/components/custom-icons.dart';
import 'package:mywonderbird/components/selection-list-item.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/routes/home/main.dart';
import 'package:mywonderbird/routes/select-journey/main.dart';
import 'package:mywonderbird/routes/select-location/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/sharing.dart';

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
    final sharePictureProvider = locator<SharePictureProvider>();

    return _selectedLocation ?? sharePictureProvider.pictureData.location;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: _content(),
          ),
        ),
      );
    });
  }

  Widget _content() {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: _image,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  style: theme.textTheme.subtitle1,
                ),
              ),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  color: Colors.red,
                  child: BodyText1.light(_error),
                ),
              SelectionListItem(
                icon: Icon(
                  CustomIcons.route,
                  color: journey != null ? theme.primaryColor : Colors.black87,
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
                  color: location != null ? theme.primaryColor : Colors.black87,
                  size: 40.0,
                ),
                changeTitle: 'Change the photo location',
                chooseTitle: 'Choose the photo location',
                item: location,
                onTap: _selectLocation,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                child: RaisedButton(
                  color: theme.primaryColor,
                  child: _isSharing
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(),
                        )
                      : BodyText1.light('Share'),
                  onPressed: _isSharing ? null : _sharePicture,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  _sharePicture() async {
    final sharingService = locator<SharingService>();
    final navigationService = locator<NavigationService>();
    final title = _titleController.text;
    final sharePictureProvider = locator<SharePictureProvider>();

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

  _selectJourney() async {
    final navigationService = locator<NavigationService>();
    final selectedJourney = await navigationService.push(
      MaterialPageRoute(
        builder: (context) => SelectJourney(
          journey: journey,
        ),
      ),
    );

    if (selectedJourney != null) {
      setState(() {
        _selectedJourney = selectedJourney;
      });
    }
  }

  _selectLocation() async {
    final navigationService = locator<NavigationService>();
    final selectedLocation = await navigationService.push(
      MaterialPageRoute(
        builder: (context) => SelectLocation(
          location: location,
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
      });
    }
  }

  ImageProvider get _image {
    final sharePictureProvider = locator<SharePictureProvider>();

    return sharePictureProvider.pictureData.image;
  }
}
