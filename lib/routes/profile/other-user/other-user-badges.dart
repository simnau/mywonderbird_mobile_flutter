import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/models/badge.dart';
import 'package:mywonderbird/routes/profile/components/achievement-list.dart';

class OtherUserBadges extends StatelessWidget {
  final List<Badge> badges;

  const OtherUserBadges({
    Key key,
    @required this.badges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: H6(
          "User's Achievements",
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white,
      body: AchievementList(badges: badges),
    );
    ;
  }
}
