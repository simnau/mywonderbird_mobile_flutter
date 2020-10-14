import 'package:flutter/material.dart';
import 'package:mywonderbird/components/bottom-nav-bar.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/select-picture/main.dart';
import 'package:mywonderbird/services/navigation.dart';

import 'components/feed.dart';
import 'components/filters.dart';
import 'components/search.dart';

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
          : Feed(
              controller: _feedController,
            ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.all(2.0),
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 36,
          ),
          onPressed: _onAddPicture,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        onHome: _onRefresh,
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
        onPressed: _filterFromFeed,
      ),
      IconButton(
        key: UniqueKey(),
        icon: Icon(Icons.search),
        onPressed: _onSearch,
      ),
    ];
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
    locator<NavigationService>().pushNamed(SelectPicture.PATH);
  }
}
