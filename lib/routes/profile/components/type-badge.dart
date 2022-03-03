import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/theme.dart';

class TypeBadge extends StatelessWidget {
  final Color backgroundColor;
  final Widget label;

  const TypeBadge({
    Key key,
    @required this.backgroundColor,
    @required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity(vertical: VisualDensity.minimumDensity),
      label: label,
      backgroundColor: backgroundColor,
      padding: EdgeInsets.all(spacingFactor(0.5)),
      labelPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadiusFactor(1),
        ),
      ),
    );
  }
}
