import 'package:flutter/material.dart';
import 'package:mywonderbird/routes/suggest-trip-questionnaire/builder-arguments.dart';

class WizardStep {
  final String key;
  final String title;
  final Widget Function(BuilderArguments) builder;
  final bool Function(dynamic) validator;
  final String Function(dynamic) stringValue;
  final ImageProvider backgroundImage;

  const WizardStep({
    @required this.key,
    @required this.title,
    @required this.builder,
    @required this.validator,
    this.stringValue,
    this.backgroundImage,
  });
}
