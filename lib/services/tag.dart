import 'dart:io';

import 'package:mywonderbird/models/tag.dart';
import 'package:mywonderbird/services/api.dart';

const TAGS_URL = '/api/tags';

class TagService {
  final API api;

  TagService({
    this.api,
  });

  Future<List<Tag>> fetchTags() async {
    final response = await api.get(TAGS_URL);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('An error occurred'); // TODO handle properly
    }
    final tags = response['body']['tags'];

    return tags.map<Tag>((tag) {
      return Tag.fromJson(tag);
    }).toList();
  }
}
