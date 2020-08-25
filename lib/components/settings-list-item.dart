import 'package:flutter/material.dart';

class SettingsListItem extends StatelessWidget {
  final void Function() onTap;
  final Widget icon;
  final String title;

  const SettingsListItem({
    Key key,
    this.onTap,
    this.icon,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      leading: icon,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 18.0,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
      ),
    );
  }
}
