import 'package:flutter/material.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/types/picture-data.dart';

import '../types/form-page-data.dart';

class FormProvider with ChangeNotifier {
  final List<PictureData> pictureDatas;
  final List<FormPageData> formPageDatas;
  Journey _lastTrip;
  Journey _selectedTrip;

  Journey get trip => _selectedTrip ?? _lastTrip;

  set lastTrip(Journey trip) {
    _lastTrip = trip;
    notifyListeners();
  }

  set selectedTrip(Journey trip) {
    _selectedTrip = trip;
    notifyListeners();
  }

  FormProvider({
    @required List<PictureData> pictureDatas,
  })  : this.formPageDatas = pictureDatas
            .map(
              (pictureData) => FormPageData(
                formKey: GlobalKey<FormState>(),
                titleController: TextEditingController(),
                descriptionController: TextEditingController(),
                location: pictureData.location,
                pictureData: pictureData,
              ),
            )
            .toList(),
        this.pictureDatas = pictureDatas;
}
