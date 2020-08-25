import 'package:flutter/material.dart';

class SettingsListIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const SettingsListIcon({
    Key key,
    this.icon,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }
}
