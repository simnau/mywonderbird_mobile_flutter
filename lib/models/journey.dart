import 'package:flutter/foundation.dart';
import 'package:layout/types/named-item.dart';
import 'package:layout/util/date.dart';
import 'package:layout/util/json.dart';

class Journey extends NamedItem {
  final String id;
  final DateTime startDate;
  final String imageUrl;

  const Journey({
    @required name,
    this.id,
    @required this.startDate,
    @required this.imageUrl,
  }) : super(name: name);

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id'],
      name: json['name'],
      startDate: json['startDate'],
      imageUrl: json['imageUrl'],
    );
  }

  factory Journey.fromRequestJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id'],
      name: json['title'],
      startDate: DateTime.parse(json['startDate']),
      imageUrl: (json['images'] ?? []).isNotEmpty ? json['images'][0] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return removeNulls({
      'id': id,
      'title': name,
      'startDate': formatDateTime(startDate),
      'imageUrl': imageUrl,
    });
  }
}
