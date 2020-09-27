import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text2.dart';
import 'package:mywonderbird/types/named-item.dart';

import 'typography/subtitle1.dart';

class SelectionListItem extends StatelessWidget {
  final Icon icon;
  final NamedItem item;
  final String changeTitle;
  final String chooseTitle;
  final VoidCallback onTap;

  SelectionListItem({
    @required this.icon,
    @required this.item,
    @required this.changeTitle,
    @required this.chooseTitle,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
        child: Row(
          children: <Widget>[
            Container(
              child: icon,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Visibility(
                    visible: item != null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Subtitle1(item?.name ?? ''),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: item != null,
                    child: BodyText2(changeTitle),
                  ),
                  Visibility(
                    visible: item == null,
                    child: Subtitle1(
                      chooseTitle,
                      color: theme.accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
