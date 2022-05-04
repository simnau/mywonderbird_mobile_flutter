import 'package:flutter/material.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/tag.dart';
import 'package:mywonderbird/services/tag.dart';
import 'package:mywonderbird/util/sentry.dart';

class TagsProvider with ChangeNotifier {
  List<Tag> _tags;
  bool _loading = true;

  List<Tag> get tags => _tags;
  bool get loading => _loading;

  Future<List<Tag>> loadTags() async {
    final tagService = locator<TagService>();

    try {
      _loading = true;
      notifyListeners();

      final tags = await tagService.fetchTags();

      _tags = List.from(tags);
      _loading = false;
      notifyListeners();

      return tags;
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}
