import 'package:flutter/material.dart';

import 'typography/subtitle1.dart';
import 'typography/subtitle2.dart';

class EmptyListPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyListPlaceholder({
    Key key,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Subtitle1(
              title,
              textAlign: TextAlign.center,
              softWrap: true,
            ),
            Padding(padding: const EdgeInsets.only(bottom: 8.0)),
            if (subtitle != null)
              Subtitle2(
                subtitle,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
          ],
        ),
      ),
    );
  }
}
