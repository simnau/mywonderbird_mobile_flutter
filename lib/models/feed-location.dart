import 'package:flutter/material.dart';

class FeedLocation {
  final String id;
  final String journeyId;
  final String imageUrl;
  final String title;
  final String country;
  final DateTime updatedAt;
  int likeCount;
  bool isLiked;
  bool isBookmarked;

  FeedLocation({
    @required this.id,
    @required this.journeyId,
    @required this.imageUrl,
    @required this.title,
    @required this.country,
    @required this.updatedAt,
    @required this.likeCount,
    @required this.isLiked,
    @required this.isBookmarked,
  });

  factory FeedLocation.fromJson(Map<String, dynamic> json) {
    return FeedLocation(
      id: json['id'],
      journeyId: json['journeyId'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      country: json['country'],
      updatedAt: DateTime.parse(json['updatedAt']),
      likeCount: json['likeCount'],
      isLiked: json['isLiked'],
      isBookmarked: json['isBookmarked'],
    );
  }
}
