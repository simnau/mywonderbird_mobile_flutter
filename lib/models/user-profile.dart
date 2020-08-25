import 'package:mywonderbird/util/json.dart';

class UserProfile {
  final String id;
  final String username;
  final String bio;
  final String avatarUrl;
  final bool acceptedNewsletter;
  final DateTime acceptedTermsAt;
  final String providerId;

  UserProfile({
    this.id,
    this.username,
    this.bio,
    this.avatarUrl,
    this.acceptedNewsletter,
    this.acceptedTermsAt,
    this.providerId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final acceptedTermsAt = json['acceptedTermsAt'];

    return UserProfile(
      id: json['id'],
      username: json['username'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      acceptedNewsletter: json['acceptedNewsletter'] ?? false,
      acceptedTermsAt:
          acceptedTermsAt != null ? DateTime.parse(acceptedTermsAt) : null,
      providerId: json['providerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return removeNulls({
      'username': username,
      'bio': bio,
      'avatarUrl': avatarUrl,
    });
  }
}
