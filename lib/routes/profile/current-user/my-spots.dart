import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/spot-stats.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/select-upload-type/main.dart';
import 'package:mywonderbird/routes/profile/components/spot-screen.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/spot-stats.dart';

class MySpots extends StatelessWidget {
  const MySpots({
    Key key,
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

    return spotStatsService.findMySpots();
  }

  Widget _shareExperiencesButton(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: _onShareExperiences,
      icon: Icon(Icons.swipe, color: Colors.white),
      label: BodyText1.light("Share your experiences!"),
      style: ElevatedButton.styleFrom(
        primary: theme.accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadiusFactor(2)),
          ),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _emptyListPlaceholder(BuildContext context) {
    return EmptyListPlaceholder(
      title: "You haven't shared any spots",
      subtitle: "Would you like to share your previous experiences?",
      action: _shareExperiencesButton(context),
    );
  }

  _onShareExperiences() {
    final navigationService = locator<NavigationService>();

    navigationService.push(
      MaterialPageRoute(builder: (_) => SelectUploadType()),
    );
  }
}
