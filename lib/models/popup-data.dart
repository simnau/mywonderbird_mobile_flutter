import 'package:flutter/material.dart';

class PopupData {
  final String title;
  final String body;
  final Widget leading;
  final Widget trailing;
  final Color backgroundColor;
  final Function() onPress;

  PopupData({
    @required this.title,
    this.body,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.onPress,
  });
}
