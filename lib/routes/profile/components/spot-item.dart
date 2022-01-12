import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/spot.dart';

class SpotItem extends StatelessWidget {
  final double size;
  final Spot spot;
  final Function(Spot spot) onView;

  const SpotItem({
    Key key,
    @required this.size,
    @required this.spot,
    @required this.onView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onView,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(borderRadiusFactor(1))),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(spot.imageUrl),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                offset: Offset(0, 2),
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onView() {
    onView(spot);
  }
}
