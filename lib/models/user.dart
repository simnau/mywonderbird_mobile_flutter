import 'package:flutter/foundation.dart';
import 'package:mywonderbird/models/user-profile.dart';

class User {
  final String id;
  final String role;
  final String provider;
  final List<String> providers;
  UserProfile profile;

  User({
    @required this.id,
    this.role,
    this.provider,
    this.providers,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      role: json['role'],
      provider: json['provider'],
      providers: json['providers'],
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
