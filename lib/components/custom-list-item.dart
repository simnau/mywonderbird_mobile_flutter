import 'package:flutter/material.dart';

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
                        Text(
                          this.title,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                        ),
                        Text(
                          this.subtitle,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
