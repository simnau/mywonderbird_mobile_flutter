import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/h6.dart';

class LocationImage extends StatelessWidget {
  final ImageProvider image;
  final int number;
  final double size;
  final double borderWidth;

  const LocationImage({
    Key key,
    @required this.image,
    @required this.number,
    double size,
    double borderWidth,
  })  : this.size = size ?? 56,
        this.borderWidth = borderWidth ?? 3,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        border: Border.all(
          color: Colors.white,
          width: borderWidth,
        ),
        image: DecorationImage(
          image: image,
          fit: BoxFit.fill,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(size)),
          color: Colors.black.withOpacity(0.15),
        ),
        alignment: Alignment.center,
        child: H6.light(
          number.toString(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
