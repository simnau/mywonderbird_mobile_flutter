import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';

class CustomListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final Function onTap;
  final Color backgroundColor;

  CustomListItem({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.leadingIcon,
    @required this.trailingIcon,
    @required this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        color: this.backgroundColor ?? Colors.transparent,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: this.onTap,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    this.leadingIcon,
                    color: theme.primaryColor.withOpacity(0.8),
                    size: 72,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Subtitle1(this.title),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                        ),
                        BodyText1(this.subtitle),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                  ),
                  Icon(
                    this.trailingIcon,
                    color: Colors.black87,
                    size: 36,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
