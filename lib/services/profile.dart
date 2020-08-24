import 'package:flutter/material.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/services/token.dart';

const PROFILE_PATH = '/api/profile';

class ProfileService {
  final API api;
  final TokenService tokenService;

  ProfileService({
    @required this.api,
    @required this.tokenService,
  });

  Future<UserProfile> getUserProfile() async {
    final response = await api.get(
      PROFILE_PATH,
    );
    final profile = UserProfile.fromJson(response['body']);
    return profile;
  }
}
