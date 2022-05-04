import 'package:flutter/material.dart';
import 'package:mywonderbird/components/achievement-badge.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/badge.dart';

class AchievementList extends StatelessWidget {
  final List<Badge> badges;

  const AchievementList({
    Key key,
    @required this.badges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return EmptyListPlaceholder(
        title: "Achievements coming soon...",
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        final badge = badges[index];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacingFactor(2)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AchievementBadge.withLevel(badge: badge),
              SizedBox(width: spacingFactor(2)),
              Expanded(child: _badgeDescription(badge, context)),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: spacingFactor(2));
      },
      itemCount: badges.length,
      padding: EdgeInsets.symmetric(vertical: spacingFactor(2)),
    );
  }

  Widget _badgeDescription(Badge badge, BuildContext context) {
    final showProgress = badge.level < badge.badgeLevels;

    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Subtitle1(badge.name),
            Subtitle2(badge.description),
            if (showProgress) _progress(badge, context),
          ],
        ),
      ),
    );
  }

  Widget _progress(Badge badge, BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          height: 24,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: badge.currentCount,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              Expanded(
                flex: badge.countToNextLevel - badge.currentCount,
                child: Container(),
              )
            ],
          ),
        ),
        Positioned.fill(
          child: Center(
            child: BodyText1("${badge.currentCount}/${badge.countToNextLevel}"),
          ),
        ),
      ],
    );
  }
}
