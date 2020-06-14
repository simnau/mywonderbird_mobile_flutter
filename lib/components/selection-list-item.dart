import 'package:flutter/material.dart';
import 'package:layout/types/named-item.dart';

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
                        Text(
                          item?.name ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: item != null,
                    child: Text(
                      changeTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: item == null,
                    child: Text(
                      chooseTitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
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
