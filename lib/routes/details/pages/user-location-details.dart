import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/routes/details/components/location-details.dart';
import 'package:mywonderbird/services/user-location.dart';
import 'package:mywonderbird/util/sentry.dart';
import 'package:mywonderbird/util/snackbar.dart';

class UserLocationDetails extends StatefulWidget {
  final String locationId;
  final String userAvatar;
  final String userName;
  final String userBio;
  final String userId;

  const UserLocationDetails({
    Key key,
    @required this.locationId,
    @required this.userAvatar,
    @required this.userName,
    @required this.userBio,
    @required this.userId,
  }) : super(key: key);

  @override
  _UserLocationDetailsState createState() => _UserLocationDetailsState();
}

class _UserLocationDetailsState extends State<UserLocationDetails> {
  bool isLoading = true;
  LocationModel location;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadLocation();
    });
  }

  loadLocation() async {
    try {
      setState(() {
        isLoading = true;
      });

      final locationService = locator<UserLocationService>();

      final location = await locationService.findById(widget.locationId);

      setState(() {
        isLoading = false;
        this.location = location;
      });
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);
      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocationDetails(
      location: location,
      isUserLocationView: true,
      userAvatar: widget.userAvatar,
      userBio: widget.userBio,
      userName: widget.userName,
      userId: widget.userId,
      isLoading: isLoading,
    );
  }
}
