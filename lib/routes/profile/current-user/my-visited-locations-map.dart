import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/country-geo-stats.dart';
import 'package:mywonderbird/models/country-stats.dart';
import 'package:mywonderbird/models/spot-stats.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/routes/details/pages/user-location-details.dart';
import 'package:mywonderbird/routes/profile/components/visited-locations-map-page.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/routes/trip-overview/saved-trip.dart';
import 'package:mywonderbird/routes/trip-overview/shared-trip.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/stats.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class MyVisitedLocationsMap extends StatefulWidget {
  final List<CountryGeoStats> visitedCountries;
  final UserProfile userProfile;

  const MyVisitedLocationsMap({
    Key key,
    @required this.visitedCountries,
    @required this.userProfile,
  }) : super(key: key);

  @override
  _MyVisitedLocationsMapState createState() => _MyVisitedLocationsMapState();
}

class _MyVisitedLocationsMapState extends State<MyVisitedLocationsMap> {
  final _mapZoomPanBehavior = MapZoomPanBehavior(
    enableDoubleTapZooming: true,
    enablePanning: true,
    enablePinching: true,
  );
  MapShapeSource _shapeSource;
  bool _isLoading = true;
  bool _isLoadingStats = false;
  int _selectedCountryIndex = 0;
  List<CountryStats> _countryStats = [];

  CountryGeoStats get _selectedCountry =>
      widget.visitedCountries[_selectedCountryIndex];

  MapLatLngBounds get _selectedCountryBounds => MapLatLngBounds(
        MapLatLng(
          _selectedCountry.boundTopLeft.latitude,
          _selectedCountry.boundBottomRight.longitude,
        ),
        MapLatLng(
          _selectedCountry.boundBottomRight.latitude,
          _selectedCountry.boundTopLeft.longitude,
        ),
      );

  @override
  void initState() {
    super.initState();

    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return VisitedLocationsMapPage(
      shapeSource: _shapeSource,
      isLoading: _isLoading,
      isLoadingStats: _isLoadingStats,
      onPreviousCountry: _onPreviousCountry,
      onNextCountry: _onNextCountry,
      onSelectCountry: _onSelectCountry,
      selectedCountryIndex: _selectedCountryIndex,
      selectedCountry: _selectedCountry,
      mapZoomPanBehavior: _mapZoomPanBehavior,
      selectedCountryStats: _countryStats,
      onViewSpot: _onViewSpot,
      onViewTrip: _onViewTrip,
      visitedCountries: widget.visitedCountries,
    );
  }

  _initData() async {
    setState(() {
      _isLoading = true;
      _isLoadingStats = true;
    });
    final statsService = locator<StatsService>();

    try {
      final countryStats = await statsService.fetchCurrentUserCountryStats(
        _selectedCountry.countryCode,
      );

      setState(() {
        _shapeSource = MapShapeSource.asset(
          'images/vector-maps/world-map.json',
          shapeDataField: 'ISO_A3',
          dataCount: widget.visitedCountries.length,
          primaryValueMapper: widget.visitedCountries.isNotEmpty
              ? (index) => widget.visitedCountries[index].countryCode
              : null,
          shapeColorValueMapper: (index) {
            return Colors.grey.shade300;
          },
        );
        _countryStats = countryStats;
        _isLoading = false;
        _isLoadingStats = false;
      });
    } catch (e) {
      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _fetchCountryStats(String countryCode) async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final statsService = locator<StatsService>();

      final countryStats = await statsService.fetchCurrentUserCountryStats(
        countryCode,
      );

      setState(() {
        _isLoadingStats = false;
        _countryStats = countryStats;
      });
    } catch (e) {
      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _onSelectCountry(int index) {
    setState(() {
      _selectedCountryIndex = index;
    });
    _fetchCountryStats(_selectedCountry.countryCode);
  }

  _onPreviousCountry() {
    setState(() {
      _selectedCountryIndex =
          (_selectedCountryIndex + 1) % widget.visitedCountries.length;
      _mapZoomPanBehavior.latLngBounds = _selectedCountryBounds;
    });
    _fetchCountryStats(_selectedCountry.countryCode);
  }

  _onNextCountry() {
    setState(() {
      _selectedCountryIndex =
          (_selectedCountryIndex - 1) % widget.visitedCountries.length;
      _mapZoomPanBehavior.latLngBounds = _selectedCountryBounds;
    });
    _fetchCountryStats(_selectedCountry.countryCode);
  }

  _onViewTrip(TripStats tripStats) async {
    final navigationService = locator<NavigationService>();
    navigationService.push(
      MaterialPageRoute(
        builder: (context) => tripStats.tripType == TripType.SHARED_TRIP
            ? SharedTripOverviewGeneric(id: tripStats.id)
            : tripStats.tripStatus == TripStatus.FINISHED
                ? SavedTripOverviewGeneric(id: tripStats.id)
                : SavedTripOverview(id: tripStats.id),
      ),
    );
  }

  _onViewSpot(SpotStats spot) {
    final navigationService = locator<NavigationService>();

    navigationService.push(MaterialPageRoute(
      builder: (_) => UserLocationDetails(
        locationId: spot.id,
        userAvatar: widget.userProfile.avatarUrl,
        userBio: widget.userProfile.bio,
        userId: widget.userProfile.providerId,
        userName: widget.userProfile.username,
      ),
    ));
  }
}
