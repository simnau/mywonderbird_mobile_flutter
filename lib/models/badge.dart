import 'package:flutter/material.dart';

class Badge {
  final String name;
  final String type;
  final String description;
  final int level;
  final int countToNextLevel;
  final int currentCount;
  final int badgeLevels;

  const Badge({
    @required this.name,
    @required this.type,
    @required this.description,
    @required this.level,
    @required this.countToNextLevel,
    @required this.currentCount,
    @required this.badgeLevels,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Badge(
      name: json['name'],
      type: json['type'],
      description: json['description'],
      level: json['level'],
      countToNextLevel: json['countToNextLevel'],
      currentCount: json['currentCount'],
      badgeLevels: json['badgeLevels'],
    );
  }
}
