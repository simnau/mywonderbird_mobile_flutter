import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/models/user-stats.dart';
import 'package:mywonderbird/providers/profile.dart';
import 'package:mywonderbird/routes/profile/components/profile-page.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:mywonderbird/services/stats.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import '../map-model.dart';

class OtherUser extends StatefulWidget {
  final String id;

  const OtherUser({
    Key key,
    @required this.id,
  }) : super(key: key);

  @override
  _OtherUserState createState() => _OtherUserState();
}

class _OtherUserState extends State<OtherUser> {
  bool _isLoading = true;
  MapShapeSource _shapeSource;
  UserStats _userStats;
  UserProfile _profile;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initStats();
    });

    super.initState();
  }

  initStats() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final profileProvider = locator<ProfileProvider>();
      final statsService = locator<StatsService>();
      final profileService = locator<ProfileService>();
      final user = await profileService.getUserById(widget.id);
      final userStats = await statsService.fetchUserStats(widget.id);

      final data = userStats.visitedCountryCodes
          .map(
              (visitedCountryCode) => MapModel(countryCode: visitedCountryCode))
          .toList();

      profileProvider.reloadProfile = false;
      setState(() {
        _shapeSource = MapShapeSource.asset(
          'images/vector-maps/world-map.json',
          shapeDataField: 'ISO_A3',
          dataCount: data.length,
          primaryValueMapper: (index) => data[index].countryCode,
          shapeColorValueMapper: (_) {
            final theme = Theme.of(context);

            return theme.accentColor;
          },
        );
        _userStats = userStats;
        _profile = user.profile;
        _isLoading = false;
      });
    } catch (error) {
      final errorSnackbar = createErrorSnackbar(
        text: "There was an error loading the user profile. Please try again",
      );

      ScaffoldMessenger.of(context).showSnackBar(errorSnackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
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

    return ProfilePage(
      onViewTrips: _onViewTrips,
      onViewPlans: _onViewPlans,
      onViewSpots: _onViewSpots,
      onOpenMap: _onOpenMap,
      onViewCurrentTrips: onViewCurrentTrips,
      onViewTrip: _onViewTrip,
      userStats: _userStats,
      profile: _profile,
      shapeSource: _shapeSource,
    );
  }

  _onViewTrip(TripStats tripStats) async {
    final navigationService = locator<NavigationService>();

    navigationService.push(
      MaterialPageRoute(
        builder: (context) => tripStats.tripType == TripType.SAVED_TRIP
            ? SavedTripOverview(
                id: tripStats.id,
              )
            : TripOverview(id: tripStats.id),
      ),
    );
  }

  _onViewTrips() {
    print("view trips");
  }

  _onViewPlans() {
    print("view plans");
  }

  onViewCurrentTrips() {
    print("view current trips");
  }

  _onViewSpots() {
    print("view spots");
  }

  _onOpenMap() {
    print("open map");
  }
}
