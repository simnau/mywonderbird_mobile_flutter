import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/theme.dart';

enum Layout {
  vertical,
  horizontal,
}

class SquareIconButton extends StatelessWidget {
  final double size;
  final Icon icon;
  final Widget label;
  final Color backgroundColor;
  final BorderSide side;
  final Color splashColor;
  final Color focusColor;
  final void Function() onPressed;
  final Layout layout;
  final EdgeInsets padding;
  final Gradient gradient;

  const SquareIconButton({
    Key key,
    @required this.size,
    @required this.icon,
    @required this.onPressed,
    this.backgroundColor,
    this.label,
    this.side,
    this.splashColor,
    this.focusColor,
    this.layout,
    this.padding,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      child: Container(
        height: layout != Layout.vertical ? size : null,
        width: layout != Layout.horizontal ? size : null,
        child: Container(
          decoration: BoxDecoration(
            border: side != null ? Border.fromBorderSide(side) : null,
            borderRadius: BorderRadius.circular(
              borderRadiusFactor(2),
            ),
            color: backgroundColor,
            gradient: gradient,
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              splashColor: splashColor,
              focusColor: focusColor,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(0),
                child: _content(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    if (label != null) {
      if (layout == Layout.horizontal) {
        return _horizontalContent();
      } else {
        return _verticalContent();
      }
    }

    return icon;
  }

  Widget _verticalContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        icon,
        label,
      ],
    );
  }

  Widget _horizontalContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        icon,
        SizedBox(width: spacingFactor(0.5)),
        label,
      ],
    );
  }
}
