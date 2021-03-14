import 'package:flutter/material.dart';
import 'package:mywonderbird/components/tag-filter/main.dart';
import 'package:mywonderbird/components/text-action-button.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/providers/swipe-filters.dart';

import 'package:mywonderbird/providers/tags.dart';
import 'package:mywonderbird/routes/swipe-locations/models/filters.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:provider/provider.dart';

class SwipeFilters extends StatefulWidget {
  @override
  _SwipeFiltersState createState() => _SwipeFiltersState();
}

class _SwipeFiltersState extends State<SwipeFilters> {
  List<String> selectedTags;

  @override
  void initState() {
    super.initState();

    final swipeFilterProvider = locator<SwipeFiltersProvider>();
    selectedTags = swipeFilterProvider.selectedTags != null
        ? List.from(swipeFilterProvider.selectedTags)
        : [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Subtitle1('Filter'),
        actions: [
          TextActionButton(
            title: 'CLEAR',
            onPress: _onClear,
            color: theme.errorColor,
          ),
          TextActionButton(
            title: 'APPLY',
            onPress: _onApply,
            color: theme.primaryColor,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    final tagsProvider = Provider.of<TagsProvider>(context);

    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TagFilter(
              tags: tagsProvider.tags,
              value: selectedTags,
              onValueChanged: _onSelectedTagsChange,
            ),
          ],
        ),
      ),
    );
  }

  _onSelectedTagsChange(List<String> newSelectedTags) {
    setState(() {
      selectedTags = newSelectedTags;
    });
  }

  _onClear() {
    final swipeFilterProvider = locator<SwipeFiltersProvider>();

    swipeFilterProvider.clear();
    _resetFilters();
  }

  _onApply() {
    final navigationService = locator<NavigationService>();

    navigationService.pop(FiltersModel(
      tags: selectedTags,
    ));
  }

  _resetFilters() {
    setState(() {
      selectedTags = [];
    });
  }
}
