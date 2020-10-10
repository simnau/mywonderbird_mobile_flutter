import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:mywonderbird/routes/profile/components/profile-app-bar.dart';
import 'package:mywonderbird/routes/profile/components/saved-trips-tab.dart';
import 'package:mywonderbird/routes/settings/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/extensions/text-theme.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
                        'SAVED TRIPS',
                        style: theme.textTheme.tab,
                      ),
                    ),
                    Tab(
                      child: Text(
                        'MY TRIPS',
                        style: theme.textTheme.tab,
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
            SavedTripsTab(),
            MyTripsTab(),
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
