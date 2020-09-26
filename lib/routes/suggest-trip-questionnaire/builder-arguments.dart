import 'package:flutter/material.dart';

class BuilderArguments {
  final FocusNode focusNode;
  final Function(dynamic) onValueChanged;
  final dynamic value;
  final Function() onComplete;

  BuilderArguments({
    this.focusNode,
    this.onValueChanged,
    this.value,
    this.onComplete,
  });
}
