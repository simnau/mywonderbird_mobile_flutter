import 'package:flutter/material.dart';
import 'package:layout/models/user-profile.dart';
import 'package:layout/services/api.dart';
import 'package:layout/services/token.dart';

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
