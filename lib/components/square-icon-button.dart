import 'package:flutter/material.dart';

class SquareIconButton extends StatelessWidget {
  final double size;
  final Icon icon;
  final Color backgroundColor;
  final void Function() onPressed;

  const SquareIconButton({
    Key key,
    @required this.size,
    @required this.icon,
    @required this.onPressed,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: backgroundColor,
        child: icon,
        onPressed: onPressed,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
