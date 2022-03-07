import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/theme.dart';

class CountrySwitch extends StatelessWidget {
  final Widget child;
  final Function() onPrevious;
  final Function() onNext;
  final bool showNavigation;

  const CountrySwitch({
    Key key,
    @required this.child,
    @required this.onPrevious,
    @required this.onNext,
    @required this.showNavigation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showNavigation)
          IconButton(
            visualDensity: VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
            splashRadius: spacingFactor(2),
            padding: EdgeInsets.all(0),
            onPressed: onPrevious,
            icon: Icon(Icons.chevron_left),
          ),
        Expanded(child: child),
        if (showNavigation)
          IconButton(
            visualDensity: VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
            splashRadius: spacingFactor(2),
            padding: EdgeInsets.all(0),
            onPressed: onNext,
            icon: Icon(Icons.chevron_right),
          )
      ],
    );
  }
}
