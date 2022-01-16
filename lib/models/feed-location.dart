import 'package:flutter/material.dart';

class FeedLocation {
  final String id;
  final String journeyId;
  final String imageUrl;
  final String title;
  final String country;
  final DateTime updatedAt;
  final String userId;
  final String userName;
  final String userBio;
  final String userAvatarUrl;
  final String locationId;
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
    @required this.userId,
    @required this.userName,
    @required this.userBio,
    @required this.userAvatarUrl,
    @required this.locationId,
  });

  factory FeedLocation.fromJson(Map<String, dynamic> json) {
    print(json);
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
      userId: json['userId'],
      userName: json['userName'],
      userBio: json['userBio'],
      userAvatarUrl: json['userAvatarUrl'],
      locationId: json['locationId'],
    );
  }
}
