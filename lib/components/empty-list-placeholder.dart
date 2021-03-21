import 'package:flutter/material.dart';

import 'typography/subtitle1.dart';
import 'typography/subtitle2.dart';

class EmptyListPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget action;

  const EmptyListPlaceholder({
    Key key,
    @required this.title,
    this.subtitle,
    this.action,
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
            ..._subtitle(),
            ..._action(),
          ],
        ),
      ),
    );
  }

  List<Widget> _subtitle() {
    if (subtitle == null) {
      return [];
    }

    return [
      SizedBox(height: 8.0),
      Subtitle2(
        subtitle,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    ];
  }

  List<Widget> _action() {
    if (action == null) {
      return [];
    }

    return [
      SizedBox(height: 8.0),
      action,
    ];
  }
}
