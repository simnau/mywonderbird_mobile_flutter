import 'package:flutter/material.dart';
import 'package:mywonderbird/components/empty-list-placeholder.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/routes/profile/components/trip-screen.dart';
import 'package:mywonderbird/services/trip-stats.dart';

class OtherUserTrips extends StatelessWidget {
  final UserProfile userProfile;

  const OtherUserTrips({
    Key key,
    @required this.userProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = "The user's finished trips";

    return TripScreen(
      title: title,
      fetchTripsFunction: _fetchTrips,
      renderTripProgress: false,
      refetchOnPop: false,
      emptyListPlaceholder: _emptyListPlaceholder(context),
    );
  }

  Widget _emptyListPlaceholder(BuildContext context) {
    return EmptyListPlaceholder(
      title: "The user has no finished trips",
    );
  }

  Future<List<TripStats>> _fetchTrips() async {
    final tripStatsService = locator<TripStatsService>();

    return tripStatsService.findTripsByUserId(userProfile.providerId);
  }
}