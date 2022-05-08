import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/popup-data.dart';

SnackBar createErrorSnackbar({
  String text,
}) {
  return SnackBar(
    content: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
    ),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
  );
}

SnackBar createSuccessSnackbar({
  String text,
}) {
  return SnackBar(
    content: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
  );
}

SnackBar createPopupSnackbar({
  PopupData popupData,
}) {
  return SnackBar(
    padding: EdgeInsets.zero,
    content: ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: spacingFactor(1),
        horizontal: spacingFactor(2),
      ),
      leading: popupData.leading,
      title: BodyText1(popupData.title),
      subtitle: BodyText1(popupData.body, color: Colors.black45),
      trailing: popupData.trailing,
      onTap: popupData.onPress,
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: popupData.backgroundColor ?? Colors.white,
  );
}
