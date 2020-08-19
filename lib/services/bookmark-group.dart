import 'dart:io';

import 'package:layout/models/bookmark-group.dart';

import 'api.dart';

const GET_BOOKMARK_GROUPS_PATH = '/api/bookmark-groups/gem-captures';
const CREATE_BOOKMARK_GROUP_PATH = '/api/bookmark-groups/gem-captures';

class BookmarkGroupService {
  final API api;

  BookmarkGroupService({this.api});

  Future<List<BookmarkGroupModel>> fetchBookmarkGroups() async {
    final response = await api.get(GET_BOOKMARK_GROUPS_PATH);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error fetching bookmark groups');
    }
    final bookmarkGroups = response['body']['bookmarkGroups'];

    return bookmarkGroups.map<BookmarkGroupModel>((bookmarkGroup) {
      return BookmarkGroupModel.fromResponseJson(bookmarkGroup);
    }).toList();
  }

  Future<BookmarkGroupModel> createBookmarkGroup(String title) async {
    final response = await api.post(CREATE_BOOKMARK_GROUP_PATH, {
      'title': title,
    });
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error creating the bookmark group');
    }
    final bookmarkGroup = response['body'];

    return BookmarkGroupModel.fromResponseJson(bookmarkGroup);
  }
}
