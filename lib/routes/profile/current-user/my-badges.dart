import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/badge.dart';
import 'package:mywonderbird/routes/profile/components/achievement-list.dart';
import 'package:mywonderbird/services/badge.dart';
import 'package:mywonderbird/util/snackbar.dart';

class MyBadges extends StatefulWidget {
  final List<Badge> badges;

  const MyBadges({
    Key key,
    this.badges,
  }) : super(key: key);

  @override
  State<MyBadges> createState() => _MyBadgesState(
        badges: badges,
      );
}

class _MyBadgesState extends State<MyBadges> {
  List<Badge> badges;
  bool _isLoading;

  _MyBadgesState({
    List<Badge> badges,
  })  : badges = badges,
        _isLoading = badges != null ? false : true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (badges == null) {
        _fetchBadges();
      }
    });
  }

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
      body: _body(),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return AchievementList(
      badges: badges,
    );
  }

  _fetchBadges() async {
    final badgeService = locator<BadgeService>();

    try {
      setState(() {
        _isLoading = true;
      });

      final loadedBadges = await badgeService.fetchBadges();

      setState(() {
        _isLoading = false;
        badges = loadedBadges;
      });
    } catch (e) {
      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
