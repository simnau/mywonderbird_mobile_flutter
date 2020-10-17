import 'package:flutter/material.dart';

class Tag {
  final String id;
  final String title;
  final String code;
  final String imageUrl;

  Tag({
    @required this.id,
    @required this.title,
    @required this.code,
    @required this.imageUrl,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      title: json['title'],
      code: json['code'],
      imageUrl: json['imageUrl'],
    );
  }
}
