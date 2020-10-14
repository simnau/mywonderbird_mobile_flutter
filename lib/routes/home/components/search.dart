import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/feed-location.dart';
import 'package:mywonderbird/services/search.dart';
import 'package:mywonderbird/util/debouncer.dart';

class Search extends StatefulWidget {
  final SearchController controller;
  final TextEditingController queryController;
  final List<String> types;

  const Search({
    Key key,
    this.controller,
    this.queryController,
    this.types,
  }) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _searchDebouncer = Debouncer(milliseconds: 300);

  List<FeedLocation> _places = [];
  bool _isLoading = false;
  String _previousSearchValue = '';

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_controllerChange);
    widget.queryController?.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChange);
    widget.queryController?.removeListener(_onSearchChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return new Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container();
  }

  _onSearchChange() {
    String text = widget.queryController.text;

    if (text == _previousSearchValue) {
      return;
    }

    _previousSearchValue = text;

    _search(text);
  }

  _search(String text) {
    if (text.isEmpty && widget.types.isEmpty) {
      setState(() {
        _places = [];
        _isLoading = false;
      });
      _searchDebouncer.cancel();
      return;
    }

    _searchDebouncer.run(() async {
      setState(() {
        _isLoading = true;
      });
      final searchService = locator<SearchService>();
      final places = await searchService.searchPlaces(
        query: text,
        types: widget.types,
      );

      setState(() {
        _places = places;
        _isLoading = false;
      });
    });
  }

  _controllerChange() {
    String text = widget.queryController.text;

    _search(text);
  }
}

class SearchController with ChangeNotifier {
  bool shouldRun = false;

  runSearch() {
    shouldRun = true;
    notifyListeners();
  }
}
