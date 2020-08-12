import 'package:flutter/material.dart';
import 'package:layout/locator.dart';
import 'package:layout/providers/journeys.dart';
import 'package:layout/routes/profile/components/profile-app-bar.dart';
import 'package:layout/routes/settings/main.dart';
import 'package:layout/services/navigation.dart';

import 'components/badges-tab.dart';
import 'components/map-tab.dart';
import 'components/trips-tab.dart';

const double AVATAR_RADIUS = 50;
const double PROGRESS_WIDTH = 8;

class Profile extends StatefulWidget {
  static const RELATIVE_PATH = 'profile';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  final _tabBarKey = GlobalKey();
  TabController _tabController;

  _ProfileState() {
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserJourneys());
  }

  @override
  void dispose() {
    super.dispose();
    locator<JourneysProvider>().clearState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Color(0xFFF2F3F7),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, value) {
          return [
            SliverPersistentHeader(
              pinned: true,
              delegate: ProfileAppBar(
                collapsedHeight: kToolbarHeight + 72,
                expandedHeight: 250,
                onSettings: _onSettings,
                tabBar: TabBar(
                  key: _tabBarKey,
                  controller: _tabController,
                  labelColor: theme.accentColor,
                  unselectedLabelColor: Colors.black45,
                  tabs: [
                    Tab(
                      child: Text(
                        'TRIPS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'MAP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'BADGES',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            TripsTab(),
            MapTab(),
            BadgesTab(),
          ],
        ),
      ),
    );
  }

  _onSettings() {
    final navigationService = locator<NavigationService>();
    navigationService.pushNamed(Settings.PATH);
  }

  _loadUserJourneys() async {
    final journeysProvider = locator<JourneysProvider>();
    await journeysProvider.loadUserJourneys();
  }
}
