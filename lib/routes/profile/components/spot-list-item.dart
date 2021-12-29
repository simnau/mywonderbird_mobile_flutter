import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/spot-stats.dart';

class SpotListItem extends StatelessWidget {
  final SpotStats spot;
  final Function(SpotStats spot) onTap;

  const SpotListItem({
    Key key,
    @required this.spot,
    @required this.onTap,
  }) : super(key: key);

  String get likeCount =>
      spot.likeCount > 99 ? "99+" : spot.likeCount.toString();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(
            borderRadiusFactor(2),
          ),
          elevation: 2,
          child: InkWell(
            onTap: _onTap,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(spot.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: spacingFactor(1),
          right: spacingFactor(1),
          child: _likeCount(),
        ),
      ],
    );
  }

  Widget _likeCount() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(borderRadiusFactor(1)),
      ),
      padding: EdgeInsets.all(spacingFactor(0.5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: 16,
            color: Colors.black54,
          ),
          SizedBox(width: spacingFactor(0.5)),
          BodyText1(
            likeCount,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  _onTap() {
    onTap(spot);
  }
}
