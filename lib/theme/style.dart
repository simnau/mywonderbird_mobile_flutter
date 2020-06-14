import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Roboto',
  primaryColor: Colors.blue[500],
  primaryColorDark: Colors.blue[700],
  primaryColorLight: Colors.blue[100],
  accentColor: Colors.deepOrange[500],
  bottomSheetTheme: BottomSheetThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    iconTheme: IconThemeData(
      color: Colors.black87,
    ),
    elevation: 0,
  ),
);
