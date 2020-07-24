import 'package:flutter/material.dart';

class SmallIconButton extends StatelessWidget {
  final void Function() onTap;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Icon icon;

  const SmallIconButton({
    Key key,
    this.padding = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    @required this.icon,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          padding: padding,
          child: icon,
        ),
      ),
    );
  }
}
