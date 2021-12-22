import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/models/user-stats.dart';
import 'package:mywonderbird/providers/profile.dart';
import 'package:mywonderbird/routes/profile/components/profile-page.dart';
import 'package:mywonderbird/routes/profile/current-user/my-current-trips.dart';
import 'package:mywonderbird/routes/profile/current-user/my-planned-trips.dart';
import 'package:mywonderbird/routes/profile/current-user/my-trips.dart';
import 'package:mywonderbird/routes/profile/map-model.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/routes/settings/main.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:mywonderbird/services/stats.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class Profile extends StatefulWidget {
  const Profile({
    Key key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with RouteAware {
  bool _isLoading = true;
  MapShapeSource _shapeSource;
  UserStats _userStats;
  UserProfile _profile;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initStats();

      final routeObserver = locator<RouteObserver<ModalRoute<void>>>();

      routeObserver.subscribe(this, ModalRoute.of(context));
    });

    super.initState();
  }

  @override
  void dispose() {
    final routeObserver = locator<RouteObserver<ModalRoute<void>>>();

    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    final profileProvider = locator<ProfileProvider>();

    if (profileProvider.reloadProfile) {
      initStats();
    }
  }

  initStats() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final profileProvider = locator<ProfileProvider>();
      final statsService = locator<StatsService>();
      final profileService = locator<ProfileService>();
      final profile = await profileService.getUserProfile();
      final userStats = await statsService.fetchCurrentUserStats();

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
        _profile = profile;
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
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _onSettings,
          ),
        ],
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
      onViewCurrentTrips: _onViewCurrentTrips,
      onViewTrip: _onViewTrip,
      userStats: _userStats,
      profile: _profile,
      shapeSource: _shapeSource,
    );
  }

  _onSettings() {
    final navigationService = locator<NavigationService>();
    navigationService.pushNamed(Settings.PATH);
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
    final navigationService = locator<NavigationService>();

    navigationService.push(
      MaterialPageRoute(builder: (_) => MyTrips()),
    );
  }

  _onViewPlans() {
    final navigationService = locator<NavigationService>();

    navigationService.push(
      MaterialPageRoute(builder: (_) => MyPlannedTrips()),
    );
  }

  _onViewCurrentTrips() {
    final navigationService = locator<NavigationService>();

    navigationService.push(
      MaterialPageRoute(builder: (_) => MyCurrentTrips()),
    );
  }

  _onViewSpots() {
    print("view spots");
  }

  _onOpenMap() {
    print("open map");
  }
}
