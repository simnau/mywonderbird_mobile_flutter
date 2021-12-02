import 'package:flutter/material.dart';
import 'package:mywonderbird/components/horizontal-separator.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/models/user-stats.dart';
import 'package:mywonderbird/providers/profile.dart';
import 'package:mywonderbird/routes/profile/components/stats.dart';
import 'package:mywonderbird/routes/profile/components/trip-highlight-card.dart';
import 'package:mywonderbird/routes/profile/components/spots.dart';
import 'package:mywonderbird/routes/saved-trip-overview/main.dart';
import 'package:mywonderbird/routes/trip-overview/main.dart';
import 'package:mywonderbird/services/stats.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/settings/main.dart';
import 'package:mywonderbird/services/navigation.dart';

class ProfileTest extends StatefulWidget {
  const ProfileTest({
    Key key,
  }) : super(key: key);

  @override
  _ProfileTestState createState() => _ProfileTestState();
}

class _ProfileTestState extends State<ProfileTest> with RouteAware {
  bool _isLoading = true;
  List<Model> _data;
  MapShapeSource _shapeSource;
  MapZoomPanBehavior _zoomPanBehavior;
  UserStats _userStats;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initStats();

      final routeObserver = locator<RouteObserver<ModalRoute<void>>>();

      routeObserver.subscribe(this, ModalRoute.of(context));
    });

    _zoomPanBehavior = MapZoomPanBehavior();
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
      final userStats = await statsService.fetchCurrentUserStats();

      _data = userStats.visitedCountryCodes
          .map((visitedCountryCode) => Model(visitedCountryCode))
          .toList();
      _shapeSource = MapShapeSource.asset(
        'images/vector-maps/world-map.json',
        shapeDataField: 'ISO_A3',
        dataCount: _data.length,
        primaryValueMapper: (index) => _data[index].countryCode,
        shapeColorValueMapper: (_) {
          final theme = Theme.of(context);

          return theme.accentColor;
        },
      );

      profileProvider.reloadProfile = false;
      setState(() {
        _userStats = userStats;
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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _topLayout(),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
                    child: BodyText1(
                      '"Collect experiences not things"',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  SizedBox(height: spacingFactor(3)),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
                    child: HorizontalSeparator(),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
                    child: Stats(
                      countryCount: _userStats.visitedCountryCodes.length,
                      plannedTripCount: _userStats.plannedTripCount,
                      spotCount: _userStats.spotCount,
                      tripCount: _userStats.tripCount,
                      onViewTrips: _onViewTrips,
                      onViewPlans: _onViewPlans,
                      onViewSpots: _onViewSpots,
                      onViewCountries: _onOpenMap,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
                    child: HorizontalSeparator(),
                  ),
                  SizedBox(height: spacingFactor(3)),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
                    child: _userContent(),
                  ),
                  SizedBox(height: spacingFactor(2)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.75, 1],
          colors: [
            Color(0xFF3098FE),
            Color(0xAA3098FE),
            Color(0x003098FE),
          ],
        ),
      ),
      padding: const EdgeInsets.only(top: kToolbarHeight / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacingFactor(2.5),
            ),
            child: AspectRatio(aspectRatio: 4 / 3, child: _map()),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        color: Colors.black26,
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://thispersondoesnotexist.com/image",
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacingFactor(2)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Subtitle1("Traveler2000"),
                      Subtitle2("@traveler.2000"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: spacingFactor(2),
          ),
        ],
      ),
    );
  }

  Widget _map() {
    return Stack(
      children: [
        Positioned.fill(
          child: SfMaps(
            layers: <MapShapeLayer>[
              MapShapeLayer(
                source: _shapeSource,
                color: Colors.white,
                loadingBuilder: (_) => Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onOpenMap,
          ),
        ),
      ],
    );
  }

  Widget _userContent() {
    return Column(
      children: [
        ..._renderTripHighlightCard(
            _userStats.currentTrip, 'Current trip', onViewCurrentTrips),
        ..._renderTripHighlightCard(
            _userStats.upcomingTrip, 'Upcoming trip', _onViewPlans),
        ..._renderTripHighlightCard(
            _userStats.lastTrip, 'Last trip', _onViewTrips),
        _renderTripSpots(),
      ],
    );
  }

  List<Widget> _renderTripHighlightCard(
    TripStats tripStats,
    String title,
    Function() onViewAll,
  ) {
    if (tripStats == null) {
      return [];
    }

    return [
      TripHighlightCard(
        title: title,
        tripStats: tripStats,
        onViewTrip: _onViewTrip,
        onViewAll: onViewAll,
      ),
    ];
  }

  Widget _renderTripSpots() {
    if (_userStats.spots.isEmpty) {
      return null;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return TripSpots(
      title: 'Visited spots',
      spots: _userStats.spots,
      allSpotCount: _userStats.spotCount,
      spotSize:
          (screenWidth - spacingFactor(2.5) * 2 - spacingFactor(1) * 3) / 4,
      onViewAllSpots: _onViewSpots,
    );
  }

  _onSettings() {
    final navigationService = locator<NavigationService>();
    navigationService.pushNamed(Settings.PATH);
  }

  _onViewTrip(TripStats tripStats) async {
    final navigationService = locator<NavigationService>();

    final refetchStats = await navigationService.push(
          MaterialPageRoute(
            builder: (context) => tripStats.tripType == TripType.SAVED_TRIP
                ? SavedTripOverview(
                    id: tripStats.id,
                  )
                : TripOverview(id: tripStats.id),
          ),
        ) ??
        false;

    if (refetchStats) {
      await initStats();
    }
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

class Model {
  final String countryCode;

  Model(this.countryCode);
}
