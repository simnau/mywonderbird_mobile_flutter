import 'package:flutter/foundation.dart';

class Terms {
  final String id;
  final String url;
  final DateTime updatedAt;

  Terms({
    @required this.id,
    @required this.url,
    @required this.updatedAt,
  });

  factory Terms.fromJson(Map<String, dynamic> json) {
    final updatedAt = json['updatedAt'];

    return Terms(
      id: json['id'],
      url: json['url'],
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt) : null,
    );
  }
}
