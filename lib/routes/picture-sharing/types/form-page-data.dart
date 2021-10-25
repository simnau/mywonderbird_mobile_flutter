import 'package:flutter/material.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/types/picture-data.dart';

class FormPageData {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final PictureData pictureData;
  LocationModel location;

  FormPageData({
    this.formKey,
    this.titleController,
    this.descriptionController,
    this.location,
    this.pictureData,
  });
}
