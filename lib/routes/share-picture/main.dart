import 'package:flutter/material.dart';
import 'package:mywonderbird/components/input-title-dialog.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/routes/home/main.dart';
import 'package:mywonderbird/routes/select-journey/main.dart';
import 'package:mywonderbird/routes/select-location/main.dart';
import 'package:mywonderbird/routes/share-picture/components/sharing-widget.dart';
import 'package:mywonderbird/services/journeys.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/sharing.dart';
import 'package:mywonderbird/util/snackbar.dart';

class ShareScreen extends StatefulWidget {
  static const RELATIVE_PATH = 'share-picture';
  static const PATH = "/$RELATIVE_PATH";

  ShareScreen();

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Journey _lastTrip;
  Journey _selectedTrip;
  LocationModel _selectedLocation;
  bool _isLoading = true;
  bool _isSharing = false;

  Journey get trip => _selectedTrip ?? _lastTrip;

  LocationModel get location {
    final sharePictureProvider = locator<SharePictureProvider>();

    return _selectedLocation ?? sharePictureProvider.pictureData.location;
  }

  ImageProvider get image {
    final sharePictureProvider = locator<SharePictureProvider>();

    return sharePictureProvider.pictureData.image;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLastTrip());
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
    if (_isLoading) {
      return new Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SharingWidget(
      onSelectTrip: _selectTrip,
      onCreateTrip: _createTrip,
      onTripChange: _onTripChange,
      trip: _lastTrip,
      onSelectLocation: _onSelectLocation,
      onLocationChange: _onLocationChange,
      location: location,
      image: image,
      formKey: _formKey,
      titleController: _titleController,
      descriptionController: _descriptionController,
    );
  }

  _loadLastTrip() async {
    final journeyService = locator<JourneyService>();
    final lastTrip = await journeyService.getLastJourney();

    setState(() {
      _lastTrip = lastTrip;
      _isLoading = false;
    });
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

      await sharingService.sharePicture(
        _titleController.text,
        _descriptionController.text,
        sharePictureProvider.pictureData,
        _selectedLocation ?? sharePictureProvider.pictureData.location,
        trip,
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

  Future<Journey> _selectTrip() async {
    final navigationService = locator<NavigationService>();
    final selectedTrip = await navigationService.push(
      MaterialPageRoute(
        builder: (context) => SelectJourney(
          journey: trip,
        ),
      ),
    );

    if (selectedTrip != null) {
      return selectedTrip;
    }

    return null;
  }

  Future<Journey> _createTrip() async {
    final title = await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InputTitleDialog(
          title: 'Create a trip',
          hint: 'Trip title',
        ),
      ),
      barrierDismissible: true,
    );

    if (title == null || title.isEmpty) {
      return null;
    }

    return Journey(name: title, startDate: DateTime.now());
  }

  _onTripChange(Journey trip) {
    setState(() {
      _selectedTrip = trip;
    });
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
