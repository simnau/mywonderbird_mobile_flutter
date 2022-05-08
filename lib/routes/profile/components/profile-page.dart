import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mywonderbird/components/horizontal-separator.dart';
import 'package:mywonderbird/components/square-icon-button.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/badge.dart';
import 'package:mywonderbird/models/trip-stats.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/models/user-stats.dart';
import 'package:mywonderbird/routes/profile/components/achievements.dart';
import 'package:mywonderbird/routes/profile/components/stats.dart';
import 'package:mywonderbird/routes/profile/components/trip-highlight-card.dart';
import 'package:mywonderbird/routes/profile/components/spots.dart';
import 'package:mywonderbird/routes/profile/components/user-avatar.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class ProfilePage extends StatelessWidget {
  final Function() onViewTrips;
  final Function() onViewPlans;
  final Function() onViewSpots;
  final Function() onOpenMap;
  final Function() onViewCurrentTrips;
  final Function(TripStats tripStats) onViewTrip;
  final Function() onShareVisitedCountries;
  final Function() onViewAllBadges;

  final UserStats userStats;
  final UserProfile profile;
  final List<Badge> badges;
  final MapShapeSource shapeSource;

  const ProfilePage(
      {Key key,
      @required this.onViewTrips,
      @required this.onViewPlans,
      @required this.onViewSpots,
      @required this.onOpenMap,
      @required this.onViewCurrentTrips,
      @required this.onViewTrip,
      @required this.userStats,
      @required this.profile,
      @required this.badges,
      @required this.shapeSource,
      this.onShareVisitedCountries,
      this.onViewAllBadges})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  ..._userBio(),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
                    child: HorizontalSeparator(),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
                    child: Stats(
                      countryCount: userStats.visitedCountryCodes.length,
                      plannedTripCount: userStats.plannedTripCount,
                      spotCount: userStats.spotCount,
                      tripCount: userStats.tripCount,
                      onViewTrips: onViewTrips,
                      onViewPlans: onViewPlans,
                      onViewSpots: onViewSpots,
                      onViewCountries: onOpenMap,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
                    child: Achievements(
                      badges: badges,
                      onViewAll: onViewAllBadges,
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
                    child: _userContent(context),
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
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: _map(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
            child: Row(
              children: [
                UserAvatar(avatarUrl: profile.avatarUrl),
                SizedBox(width: spacingFactor(2)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // TODO: this is actually more of a display name rather than username
                      Subtitle1(
                        profile.username != null && profile.username.isNotEmpty
                            ? profile.username
                            : 'Anonymous',
                      ),
                      // TODO: this should be the username which should have stricter rules to it
                      // Subtitle2("@traveler.2000"),
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

  List<Widget> _userBio() {
    if (profile?.bio == null || profile.bio.isNotEmpty) {
      return [];
    }

    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: spacingFactor(2.5)),
        child: BodyText1(
          '"${profile.bio}"',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      SizedBox(height: spacingFactor(3)),
    ];
  }

  Widget _map() {
    return Stack(
      children: [
        Positioned.fill(
          child: Hero(
            tag: 'visited_country_map',
            child: SfMaps(
              layers: <MapShapeLayer>[
                MapShapeLayer(
                  source: shapeSource,
                  color: Colors.white,
                  loadingBuilder: (_) => Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onOpenMap,
            onScaleStart: (_) => onOpenMap(),
          ),
        ),
        if (onShareVisitedCountries != null)
          Positioned(
              bottom: 0,
              right: 0,
              child: SquareIconButton(
                icon: Icon(
                  MaterialCommunityIcons.share,
                  size: 24,
                  color: Colors.white,
                ),
                onPressed: onShareVisitedCountries,
                size: 40,
                backgroundColor: Colors.grey.shade300.withOpacity(0.5),
              )),
      ],
    );
  }

  Widget _userContent(BuildContext context) {
    return Column(
      children: [
        ..._renderTripHighlightCard(
          userStats.currentTrip,
          'Current trip',
          onViewCurrentTrips,
          renderProgress: true,
        ),
        ..._renderTripHighlightCard(
          userStats.upcomingTrip,
          'Upcoming trip',
          onViewPlans,
        ),
        ..._renderTripHighlightCard(
          userStats.lastTrip,
          'Last trip',
          onViewTrips,
        ),
        ..._renderTripSpots(context),
      ],
    );
  }

  List<Widget> _renderTripHighlightCard(
    TripStats tripStats,
    String title,
    Function() onViewAll, {
    bool renderProgress = false,
  }) {
    if (tripStats == null) {
      return [];
    }

    return [
      TripHighlightCard(
        title: title,
        tripStats: tripStats,
        onViewTrip: onViewTrip,
        onViewAll: onViewAll,
        renderProgress: renderProgress,
      ),
      SizedBox(height: spacingFactor(3)),
    ];
  }

  List<Widget> _renderTripSpots(BuildContext context) {
    if (userStats.spots.isEmpty) {
      return [];
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return [
      SizedBox(height: spacingFactor(1)),
      Spots(
        title: 'Visited spots',
        spots: userStats.spots,
        allSpotCount: userStats.spotCount,
        spotSize:
            (screenWidth - spacingFactor(2.5) * 2 - spacingFactor(1) * 3) / 4,
        onViewAllSpots: onViewSpots,
        userProfile: profile,
      ),
    ];
  }
}
