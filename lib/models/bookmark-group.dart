import 'package:flutter/material.dart';

class BookmarkGroupModel {
  final String id;
  final String title;
  final int bookmarkCount;
  final String imageUrl;

  const BookmarkGroupModel({
    @required this.id,
    @required this.title,
    @required this.bookmarkCount,
    @required this.imageUrl,
  });

  factory BookmarkGroupModel.fromResponseJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return BookmarkGroupModel(
      id: json['id'],
      title: json['title'],
      bookmarkCount: json['bookmarkCount'],
      imageUrl: json['imageUrl'],
    );
  }
}
