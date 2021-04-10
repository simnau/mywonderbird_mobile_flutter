import 'package:flutter/material.dart';

import 'typography/subtitle1.dart';

class SettingsListItem extends StatelessWidget {
  final void Function() onTap;
  final Widget icon;
  final Widget trailing;
  final String title;
  final bool hideTrailing;

  const SettingsListItem({
    Key key,
    this.onTap,
    this.icon,
    this.title,
    this.hideTrailing = false,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing ?? Icon(Icons.chevron_right);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      leading: icon,
      title: Subtitle1(title),
      trailing: hideTrailing
          ? null
          : trailingWidget,
    );
  }
}
