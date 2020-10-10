import 'package:flutter/foundation.dart';
import 'package:mywonderbird/types/named-item.dart';
import 'package:mywonderbird/util/date.dart';
import 'package:mywonderbird/util/json.dart';

class Journey extends NamedItem {
  final String id;
  final DateTime startDate;
  final DateTime finishDate;
  final String imageUrl;
  final String country;

  const Journey({
    @required name,
    this.id,
    this.country,
    @required this.startDate,
    this.finishDate,
    @required this.imageUrl,
  }) : super(name: name);

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id'],
      name: json['name'],
      startDate: json['startDate'],
      finishDate: json['finishDate'],
      imageUrl: json['imageUrl'],
      country: json['country'],
    );
  }

  factory Journey.fromRequestJson(Map<String, dynamic> json) {
    final startDate = json['startDate'];
    final finishDate = json['finishDate'];

    return Journey(
      id: json['id'],
      name: json['title'],
      startDate: startDate != null ? DateTime.parse(json['startDate']) : null,
      finishDate:
          finishDate != null ? DateTime.parse(json['finishDate']) : null,
      imageUrl: (json['images'] ?? []).isNotEmpty ? json['images'][0] : null,
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return removeNulls({
      'id': id,
      'title': name,
      'startDate': formatDateTime(startDate),
      'imageUrl': imageUrl,
      'country': country,
    });
  }
}
