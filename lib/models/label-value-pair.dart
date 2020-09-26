import 'package:flutter/material.dart';

class LabelValuePair {
  final dynamic value;
  final String label;

  LabelValuePair({
    @required this.value,
    @required this.label,
  });

  factory LabelValuePair.fromJson(Map<String, dynamic> json) {
    return LabelValuePair(
      value: json['value'],
      label: json['label'],
    );
  }
}
