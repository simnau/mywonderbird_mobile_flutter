import 'package:flutter/material.dart';

class ShowcaseIcon extends StatelessWidget {
  final Icon icon;

  ShowcaseIcon({
    @required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColorLight,
            theme.primaryColor,
          ],
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: icon,
    );
  }
}
