import 'package:flutter/material.dart';

class SquareIconButton extends StatelessWidget {
  final double size;
  final Icon icon;
  final Widget label;
  final Color backgroundColor;
  final BorderSide side;
  final Color splashColor;
  final Color focusColor;
  final void Function() onPressed;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: backgroundColor,
        child: _content(),
        onPressed: onPressed,
        elevation: 0,
        highlightElevation: 0,
        shape: side != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: side,
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
        splashColor: splashColor,
        focusColor: focusColor,
      ),
    );
  }

  Widget _content() {
    if (label != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          icon,
          SizedBox(
            height: 4.0,
          ),
          label,
        ],
      );
    }

    return icon;
  }
}
