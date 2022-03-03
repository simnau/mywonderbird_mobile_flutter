import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text2.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/spot-stats.dart';
import 'package:mywonderbird/routes/profile/components/type-badge.dart';

const double CARD_HEIGHT = 215;

class SpotCard extends StatelessWidget {
  final SpotStats spotStats;
  final Function(SpotStats spotStats) onViewSpot;
  final bool showType;

  const SpotCard({
    Key key,
    @required this.spotStats,
    @required this.onViewSpot,
    bool showType,
  })  : showType = showType ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CARD_HEIGHT,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadiusFactor(4))),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 4),
            color: Colors.black26,
          ),
        ],
      ),
      child: _card(context),
    );
  }

  Widget _card(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        image: spotStats.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(spotStats.imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      height: CARD_HEIGHT,
      child: Container(
        color: Colors.black26,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _viewSpot,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: showType
                      ? ListTile(
                          trailing: TypeBadge(
                            label: BodyText2('Spot', color: Colors.black87),
                            backgroundColor: theme.primaryColorLight,
                          ),
                        )
                      : Container(),
                ),
                ListTile(
                  title: H6.light(spotStats.name),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _viewSpot() {
    onViewSpot(spotStats);
  }
}
