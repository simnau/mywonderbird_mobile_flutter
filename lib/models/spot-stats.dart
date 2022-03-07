import 'package:flutter/material.dart';

class SpotStats {
  final String id;
  final String imageUrl;
  final String country;
  final String countryCode;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SpotStats({
    @required this.id,
    @required this.imageUrl,
    @required this.country,
    @required this.countryCode,
    @required this.likeCount,
    @required this.createdAt,
    @required this.updatedAt,
  });

  factory SpotStats.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    final updatedAt = json['updatedAt'];

    return SpotStats(
      id: json['id'],
      imageUrl: json['imageUrl'],
      country: json['country'],
      countryCode: json['countryCode'],
      likeCount: json['likeCount'],
      createdAt: createdAt != null ? DateTime.parse(createdAt) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt) : null,
    );
  }
}
