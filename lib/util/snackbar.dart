import 'package:flutter/material.dart';

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
