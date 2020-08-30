import 'package:flutter/foundation.dart';
import 'package:mywonderbird/models/user-profile.dart';

class User {
  final String id;
  final String role;
  final String provider;
  UserProfile profile;

  User({
    @required this.id,
    @required this.role,
    @required this.provider,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      role: json['role'],
      provider: json['provider'],
    );
  }

  String get username {
    return profile?.username ?? 'Anonymous';
  }

  String get initials {
    return profile?.username?.substring(0, 2)?.toUpperCase() ?? '??';
  }

  String get level {
    return 'Beginner';
  }
}
