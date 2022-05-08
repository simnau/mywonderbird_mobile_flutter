import 'package:flutter/material.dart';
import 'package:mywonderbird/components/achievement-badge.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/badge.dart';

class Achievements extends StatefulWidget {
  final List<Badge> badges;
  final Function() onViewAll;

  const Achievements({
    Key key,
    @required this.badges,
    @required this.onViewAll,
  }) : super(key: key);

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  final _listViewController = ScrollController();
  bool _hasReachedEnd = true;
  bool _hasReachedStart = true;

  List<Badge> get achievedBadges {
    return widget.badges.where((element) => element.level > 0).toList();
  }

  @override
  void initState() {
    super.initState();
    _listViewController.addListener(_listenForScrollEnd);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final maxScroll = _listViewController.position.maxScrollExtent;
      final currentScroll = _listViewController.position.pixels;

      setState(() {
        _hasReachedEnd = maxScroll - currentScroll <= 0;
        _hasReachedStart = currentScroll <= 0;
      });
    });
  }

  @override
  void dispose() {
    _listViewController.removeListener(_listenForScrollEnd);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Subtitle1(
                "Achievements",
                color: Color(0xFF484242),
              ),
              if (widget.onViewAll != null)
                TextButton(
                  onPressed: widget.onViewAll,
                  child: Row(
                    children: [
                      Subtitle2(
                        "More",
                        color: Colors.black45,
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.black45,
                      )
                    ],
                  ),
                  style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                ),
            ],
          ),
        ),
        _badges(),
        SizedBox(height: spacingFactor(2)),
      ],
    );
  }

  Widget _badges() {
    if (achievedBadges.isEmpty) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: Subtitle2("You have no badges"),
      );
    }

    return Container(
      height: 80,
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView.separated(
              controller: _listViewController,
              itemBuilder: (buildContext, index) {
                final badge = achievedBadges[index];

                return AchievementBadge(
                  badge: badge,
                  size: 80.0,
                );
              },
              scrollDirection: Axis.horizontal,
              itemCount: achievedBadges.length,
              separatorBuilder: (_, __) {
                return SizedBox(width: spacingFactor(1));
              },
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _hasReachedStart ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.white.withAlpha(0),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _hasReachedEnd ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withAlpha(0),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _listenForScrollEnd() {
    final maxScroll = _listViewController.position.maxScrollExtent;
    final currentScroll = _listViewController.position.pixels;

    setState(() {
      setState(() {
        _hasReachedEnd = maxScroll - currentScroll <= 0;
        _hasReachedStart = currentScroll <= 0;
      });
    });
  }
}
