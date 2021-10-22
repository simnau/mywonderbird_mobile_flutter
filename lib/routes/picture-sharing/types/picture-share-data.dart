import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/types/picture-data.dart';
import 'package:mywonderbird/util/date.dart';

import 'form-page-data.dart';

class PictureShareData {
  final String title;
  final String description;
  final LocationModel location;
  final PictureData pictureData;

  PictureShareData({
    this.title,
    this.description,
    this.location,
    this.pictureData,
  });

  factory PictureShareData.fromFormPageData(FormPageData formPageData) {
    return PictureShareData(
      title: formPageData.titleController.text,
      description: formPageData.descriptionController.text,
      location: formPageData.location,
      pictureData: formPageData.pictureData,
    );
  }

  Map<String, String> toStringJson() {
    return {
      'title': title,
      'description': description,
      'creationDate': formatDateTime(pictureData.creationDate),
      ...location.toStringJson(),
    };
  }
}
