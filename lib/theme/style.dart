import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Montserrat',
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
        Radius.circular(40.0),
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    iconTheme: IconThemeData(
      color: Colors.black87,
    ),
    elevation: 0,
  ),
  textTheme: TextTheme(
    headline5: TextStyle(
      fontSize: 24.0,
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    ),
    headline6: TextStyle(
      fontSize: 20.0,
      color: Colors.black45,
      fontWeight: FontWeight.w500,
    ),
    subtitle1: TextStyle(
      fontSize: 18.0,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    ),
    subtitle2: TextStyle(
      fontSize: 16.0,
      color: Colors.black45,
    ),
    bodyText1: TextStyle(
      fontSize: 14.0,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    ),
    bodyText2: TextStyle(
      fontSize: 12.0,
      color: Colors.black45,
    ),
  ),
);
