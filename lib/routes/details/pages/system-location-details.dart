import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/routes/details/components/location-details.dart';
import 'package:mywonderbird/services/system-location.dart';
import 'package:mywonderbird/util/snackbar.dart';

class SystemLocationDetails extends StatefulWidget {
  final String locationId;

  const SystemLocationDetails({
    Key key,
    @required this.locationId,
  }) : super(key: key);

  @override
  _SystemLocationDetailsState createState() => _SystemLocationDetailsState();
}

class _SystemLocationDetailsState extends State<SystemLocationDetails> {
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

      final locationService = locator<SystemLocationService>();

      final location = await locationService.findById(widget.locationId);

      setState(() {
        isLoading = false;
        this.location = location;
      });
    } catch (e) {
      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return LocationDetails(
      location: location,
    );
  }
}
