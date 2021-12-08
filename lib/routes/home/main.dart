import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/bottom-nav-bar.dart';
import 'package:mywonderbird/components/typography/h6.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/constants/analytics-events.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/functionality-coming-soon/main.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/select-upload-type/main.dart';
import 'package:mywonderbird/routes/profile/current-user/main.dart';
import 'package:mywonderbird/routes/swipe-locations/main.dart';
import 'package:mywonderbird/services/navigation.dart';

import 'components/feed.dart';
import 'components/filters.dart';
import 'components/search.dart';

const SHARE_PHOTO_FEATURE = 'share_photo_feed';
const PLANNING_FEATURE = 'planning_feed';
const PROFILE_FEATURE = 'profile_feed';

class HomePage extends StatefulWidget {
  static const RELATIVE_PATH = 'home';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _feedController = FeedController();
  final _searchController = SearchController();
  final _searchQueryController = TextEditingController();
  final _focusNode = FocusNode();
  bool _searching = false;
  bool _autoFocus = false;

  List<String> _selectedTypes = [];

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FeatureDiscovery.discoverFeatures(context, <String>[
        SHARE_PHOTO_FEATURE,
        PLANNING_FEATURE,
        PROFILE_FEATURE,
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Color(0xFFF2F3F7),
      appBar: AppBar(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.accentColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'images/logo@025x.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: _title(),
        actions: _actions(),
      ),
      body: _searching
          ? Search(
              controller: _searchController,
              queryController: _searchQueryController,
              types: _selectedTypes,
            )
          : Feed(controller: _feedController),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.all(2.0),
        child: DescribedFeatureOverlay(
          barrierDismissible: false,
          featureId: SHARE_PHOTO_FEATURE,
          tapTarget: Icon(
            Icons.add,
            size: 36,
          ),
          title: H6.light('Share photo'),
          description: Subtitle2.light(
            'Tap the plus icon to share photos from your trips',
          ),
          backgroundColor: Theme.of(context).accentColor,
          targetColor: Colors.white,
          textColor: Colors.white,
          child: FloatingActionButton(
            child: Icon(
              Icons.add,
              size: 36,
            ),
            onPressed: _onAddPicture,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        onHome: _onRefresh,
        onTripPlanning: _onTripPlanning,
      ),
    );
  }

  Widget _title() {
    if (_searching) {
      return TextField(
        autofocus: _autoFocus,
        focusNode: _focusNode,
        controller: _searchQueryController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search...',
        ),
      );
    }

    return Subtitle1('MyWonderbird');
  }

  List<Widget> _actions() {
    final theme = Theme.of(context);

    if (_searching) {
      return [
        IconButton(
          key: UniqueKey(),
          icon: Icon(Icons.filter_list),
          color: _selectedTypes.isNotEmpty ? theme.primaryColorDark : null,
          onPressed: _filter,
        ),
        IconButton(
          key: UniqueKey(),
          icon: Icon(Icons.close),
          onPressed: _closeSearch,
        ),
      ];
    }

    return [
      IconButton(
        key: UniqueKey(),
        icon: Icon(Icons.filter_list),
        // onPressed: _filterFromFeed, TODO: add this back once it's implemented properly
        onPressed: _showComingSoonFilter,
      ),
      IconButton(
        key: UniqueKey(),
        icon: Icon(Icons.search),
        // onPressed: _onSearch, TODO: add this back once it's implemented properly
        onPressed: _showComingSoonSearch,
      ),
      DescribedFeatureOverlay(
        barrierDismissible: false,
        featureId: PROFILE_FEATURE,
        tapTarget: Icon(Icons.person),
        title: H6.light('Your profile'),
        description: Subtitle2.light(
          'Access your saved or created trips, update your settings and more',
        ),
        backgroundColor: Theme.of(context).accentColor,
        child: IconButton(
          key: UniqueKey(),
          icon: Icon(Icons.person),
          onPressed: _onNavigateToProfile,
        ),
      )
    ];
  }

  _showComingSoonFilter() {
    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: FEED_FILTER);
    locator<NavigationService>().pushNamed(ComingSoonScreen.PATH);
  }

  _showComingSoonSearch() {
    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: FEED_SEARCH);
    locator<NavigationService>().pushNamed(ComingSoonScreen.PATH);
  }

  _onNavigateToProfile() {
    locator<NavigationService>().push(MaterialPageRoute(
      builder: (_) => Profile(),
    ));
  }

  _onRefresh() {
    _feedController.refresh();
  }

  _onSearch() {
    setState(() {
      _autoFocus = true;
      _searching = true;
    });
  }

  _onTripPlanning() {
    final navigationService = locator<NavigationService>();
    navigationService.push(
      MaterialPageRoute(
        builder: (context) => SwipeLocations(),
      ),
    );
  }

  _closeSearch() {
    setState(() {
      _autoFocus = false;
      _searching = false;
      _searchQueryController.text = '';
      _selectedTypes = [];
    });
  }

  _filterFromFeed() async {
    final selectedTypes = await _selectFilters();

    if (selectedTypes == null) {
      return;
    }

    setState(() {
      _autoFocus = false;
      _searching = true;
      _selectedTypes = selectedTypes;
      _searchController.runSearch();
    });
  }

  _filter() async {
    setState(() {
      _autoFocus = false;
    });

    _focusNode.unfocus();
    final selectedTypes = await _selectFilters();

    if (selectedTypes == null) {
      return;
    }

    setState(() {
      _selectedTypes = selectedTypes;
      _searchController.runSearch();
    });
  }

  Future<List<String>> _selectFilters() async {
    final navigationService = locator<NavigationService>();
    final selectedTypes = await navigationService.push(MaterialPageRoute(
      builder: (context) => Filters(
        types: _selectedTypes,
      ),
    ));

    return selectedTypes;
  }

  _onAddPicture() {
    locator<NavigationService>().push(MaterialPageRoute(
      builder: (_) => SelectUploadType(),
    ));

    final analytics = locator<FirebaseAnalytics>();
    analytics.logEvent(name: INIT_PHOTO_UPLOAD);
  }
}
