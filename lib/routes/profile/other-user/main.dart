import 'package:flutter/material.dart';
import 'package:mywonderbird/components/profile-app-bar.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:mywonderbird/extensions/text-theme.dart';

import 'components/trips-tab.dart';
import 'components/saved-trips-tab.dart';
import 'components/spots-tab.dart';

class OtherUser extends StatefulWidget {
  final String id;

  const OtherUser({
    Key key,
    @required this.id,
  }) : super(key: key);

  @override
  _OtherUserState createState() => _OtherUserState();
}

class _OtherUserState extends State<OtherUser> with TickerProviderStateMixin {
  final _tabBarKey = GlobalKey();
  TabController _tabController;

  bool _isLoading = true;
  User _user;

  _OtherUserState() {
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F3F7),
      body: _body(),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final theme = Theme.of(context);

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, value) {
        return [
          SliverPersistentHeader(
            pinned: true,
            delegate: ProfileAppBar(
              collapsedHeight: kToolbarHeight + 72,
              expandedHeight: 250,
              user: _user,
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
                      'TRIPS',
                      style: theme.textTheme.tab,
                    ),
                  ),
                  Tab(
                    child: Text(
                      'SPOTS',
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
          SavedTripsTab(userId: widget.id),
          TripsTab(userId: widget.id),
          SpotsTab(userId: widget.id),
        ],
      ),
    );
  }

  _loadUser() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final profileService = locator<ProfileService>();
      final user = await profileService.getUserById(widget.id);

      setState(() {
        _isLoading = false;
        _user = user;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }
}
