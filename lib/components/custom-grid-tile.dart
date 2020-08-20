import 'package:flutter/material.dart';

class CustomGridTile extends StatelessWidget {
  final Widget child;
  final Widget trailing;
  final Widget header;
  final void Function() onTap;

  const CustomGridTile({
    Key key,
    this.child,
    this.trailing,
    this.onTap,
    this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: child),
                if (trailing != null) trailing,
              ],
            ),
            if (onTap != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                  ),
                ),
              ),
            if (header != null)
              Positioned(
                top: 0,
                right: 0,
                child: header,
              ),
          ],
        ),
      ),
    );
  }
}
