import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/models/badge.dart';
import 'package:mywonderbird/routes/profile/components/achievement-list.dart';

class MyBadges extends StatelessWidget {
  final List<Badge> badges;

  const MyBadges({
    Key key,
    @required this.badges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: H6(
          "My Achievements",
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white,
      body: AchievementList(badges: badges),
    );
  }
}
