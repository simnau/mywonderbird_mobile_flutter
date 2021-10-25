import 'package:flutter/material.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/routes/picture-sharing/components/sharing-widget.dart';
import 'package:mywonderbird/routes/picture-sharing/providers/form.dart';
import 'package:mywonderbird/types/picture-data.dart';
import 'package:provider/provider.dart';

class FormPage extends StatelessWidget {
  final PictureData pictureData;
  final int index;
  final Journey trip;
  final Future<Journey> Function() onSelectTrip;
  final Future<Journey> Function() onCreateTrip;
  final Function(Journey trip) onTripChange;
  final Future<LocationModel> Function() onSelectLocation;
  final Function(LocationModel) onLocationChange;
  final LocationModel location;
  final bool isSingle;

  const FormPage({
    Key key,
    @required this.pictureData,
    @required this.index,
    this.trip,
    this.onSelectTrip,
    this.onCreateTrip,
    this.onTripChange,
    @required this.onSelectLocation,
    @required this.location,
    @required this.onLocationChange,
    bool isSingle,
  })  : this.isSingle = isSingle ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);

    final formPageData = formProvider.formPageDatas[index];

    return SharingWidget(
      images: pictureData.images,
      formKey: formPageData.formKey,
      titleController: formPageData.titleController,
      descriptionController: formPageData.descriptionController,
      trip: trip,
      onSelectTrip: onSelectTrip,
      onCreateTrip: onCreateTrip,
      onTripChange: onTripChange,
      onLocationChange: onLocationChange,
      onSelectLocation: onSelectLocation,
      location: location,
      single: isSingle,
    );
  }
}
