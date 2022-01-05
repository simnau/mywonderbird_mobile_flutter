import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/select-upload-type/main.dart';
import 'package:mywonderbird/routes/profile/components/trip-screen.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/trip-stats.dart';

class MyTrips extends StatelessWidget {
  const MyTrips({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TripScreen(
      title: 'My finished trips',
      fetchTripsFunction: _fetchTrips,
      renderTripProgress: false,
      actionButton: _shareExperiencesButton(context),
      emptyListPlaceholder: _emptyListPlaceholder(context),
      showItemActions: true,
    );
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
      title: "You have no finished trips",
      subtitle: "Would you like to share your previous experiences?",
      action: _shareExperiencesButton(context),
    );
  }

  Future<List<TripStats>> _fetchTrips() async {
    final tripStatsService = locator<TripStatsService>();

    return tripStatsService.findMyTrips();
  }

  _onShareExperiences() {
    final navigationService = locator<NavigationService>();

    navigationService.push(
      MaterialPageRoute(builder: (_) => SelectUploadType()),
    );
  }
}
