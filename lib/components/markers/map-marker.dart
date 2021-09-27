import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/typography/h5.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';

class MapMarker extends StatelessWidget {
  final int number;
  final IconData icon;
  final Color color;
  final Color decorationColor;

  const MapMarker({
    Key key,
    this.number,
    this.icon,
    this.color,
    this.decorationColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Transform.scale(
        scale: 1.2,
        child: Stack(children: [
          Icon(
            MaterialCommunityIcons.map_marker,
            size: 104,
            color: Colors.grey[900],
          ),
          Positioned.fill(
            top: 3,
            child: Align(
              alignment: Alignment.topCenter,
              child: Icon(
                MaterialCommunityIcons.map_marker,
                size: 96,
                color: color ?? Colors.deepOrange[500],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.topCenter,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[900],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              width: 36,
              height: 36,
              alignment: Alignment.topCenter,
              child: Align(
                alignment: Alignment.center,
                child: _decoration(),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _decoration() {
    if (number != null) {
      if (number < 10) {
        return H5(
          number.toString(),
          color: decorationColor ?? Colors.white,
        );
      } else if (number < 100) {
        return Subtitle1(
          number.toString(),
          color: decorationColor ?? Colors.white,
        );
      } else {
        return Icon(
          Icons.more_horiz,
          color: decorationColor ?? Colors.white,
        );
      }
    }

    if (icon != null) {
      return Icon(
        icon,
        color: decorationColor ?? Colors.white,
      );
    }

    return null;
  }
}
