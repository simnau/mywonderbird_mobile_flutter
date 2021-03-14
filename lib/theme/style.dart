import 'package:flutter/material.dart';

// Old flat button style
final flatButtonStyle = TextButton.styleFrom(
  primary: Colors.black87,
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16.0),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2.0)),
  ),
);

// Old raised button style
final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: Colors.grey[300],
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  ),
);

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
  textButtonTheme: TextButtonThemeData(style: flatButtonStyle),
  elevatedButtonTheme: ElevatedButtonThemeData(style: raisedButtonStyle),
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
