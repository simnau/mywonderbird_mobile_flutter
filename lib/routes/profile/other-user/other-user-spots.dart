import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/spot-stats.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/routes/profile/components/spot-screen.dart';
import 'package:mywonderbird/services/spot-stats.dart';

class OtherUserSpots extends StatelessWidget {
  final UserProfile userProfile;

  const OtherUserSpots({
    Key key,
    @required this.userProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpotScreen(
      title: 'My spots',
      fetchSpotsFunction: _fetchSpots,
      emptyListPlaceholder: _emptyListPlaceholder(context),
    );
  }

  Future<List<SpotStats>> _fetchSpots() async {
    final spotStatsService = locator<SpotStatsService>();

    return spotStatsService.findSpotsByUserId(userProfile.providerId);
  }

  Widget _emptyListPlaceholder(BuildContext context) {
    return EmptyListPlaceholder(
      title: "The user has not shared any spots",
    );
  }
}
