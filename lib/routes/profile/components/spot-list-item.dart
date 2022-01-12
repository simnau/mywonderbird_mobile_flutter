import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/spot-stats.dart';

class SpotListItem extends StatelessWidget {
  final SpotStats spot;
  final Function(SpotStats spot) onTap;
  final Function(SpotStats spot) onDelete;
  final bool showActions;

  const SpotListItem({
    Key key,
    @required this.spot,
    @required this.onTap,
    @required this.showActions,
    this.onDelete,
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
        if (showActions)
          Positioned(
            top: 0,
            right: 0,
            child: _actions(context),
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

  Widget _actions(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton(
        icon: Icon(
          Icons.more_horiz,
          color: Colors.white,
        ),
        iconSize: 24,
        tooltip: "Action menu",
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadiusFactor(2),
          ),
        ),
        itemBuilder: (_) {
          return <PopupMenuEntry>[
            PopupMenuItem(
              child: Subtitle2(
                "Delete",
                color: Colors.black87,
              ),
              onTap: _delete,
            ),
          ];
        },
      ),
    );
  }

  _onTap() {
    onTap(spot);
  }

  _delete() {
    if (!showActions) {
      return;
    }

    // This makes sure that the item is closed when onDelete is invoked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onDelete(spot);
    });
  }
}
