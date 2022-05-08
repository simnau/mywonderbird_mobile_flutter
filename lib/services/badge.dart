import 'dart:io';

import 'package:mywonderbird/models/badge.dart';

import 'api.dart';

const ROOT_BADGES_PATH = '/api/badges';
const GET_BADGES_PATH = ROOT_BADGES_PATH;
final getBadgesByUserIdPath = (String userId) => "$ROOT_BADGES_PATH/$userId";

class BadgeService {
  final API api;

  BadgeService({this.api});

  Future<List<Badge>> fetchBadges() async {
    final response = await api.get(GET_BADGES_PATH);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error fetching bookmark groups');
    }
    final badges = response['body']['badges'];

    return badges.map<Badge>((badge) {
      return Badge.fromJson(badge);
    }).toList();
  }

  Future<List<Badge>> fetchBadgesByUserId(String userId) async {
    final response = await api.get(getBadgesByUserIdPath(userId));
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception('There was an error fetching bookmark groups');
    }
    final badges = response['body']['badges'];

    return badges.map<Badge>((badge) {
      return Badge.fromJson(badge);
    }).toList();
  }
}
