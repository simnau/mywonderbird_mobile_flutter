import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/h6.dart';

import 'location-state.dart';

class LocationImage extends StatelessWidget {
  final ImageProvider image;
  final int number;
  final double size;
  final double borderWidth;
  final LocationState state;

  const LocationImage({
    Key key,
    @required this.image,
    @required this.number,
    double size,
    double borderWidth,
    this.state,
  })  : this.size = size ?? 56,
        this.borderWidth = borderWidth ?? 3,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = colorFromLocationState(state, theme);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        border: Border.all(
          color: color,
          width: borderWidth,
        ),
        image: image != null
            ? DecorationImage(
                image: image,
                fit: BoxFit.fill,
              )
            : null,
        color: image != null ? null : Colors.grey,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(size)),
          color: Colors.black.withOpacity(0.1),
        ),
        alignment: Alignment.center,
        child: H6(
          number.toString(),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
