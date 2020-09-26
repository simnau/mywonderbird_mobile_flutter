import 'package:flutter/material.dart';
import 'package:mywonderbird/types/named-item.dart';

class SuggestedLocationImage extends NamedItem {
  final String id;
  final String url;

  const SuggestedLocationImage({
    this.id,
    @required name,
    @required this.url,
  }) : super(name: name);

  factory SuggestedLocationImage.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return SuggestedLocationImage(
      id: json['id'],
      name: json['name'],
      url: json['url'],
    );
  }
}
