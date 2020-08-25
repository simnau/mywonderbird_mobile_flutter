import 'package:flutter/material.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/services/token.dart';

const PROFILE_PATH = '/api/profile';
const UPDATE_COMMUNICATIONS_PATH = "$PROFILE_PATH/communication";

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

  Future<UserProfile> updateUserProfile(UserProfile userProfileUpdate) async {
    final response = await api.post(
      PROFILE_PATH,
      userProfileUpdate.toJson(),
    );
    final profile = UserProfile.fromJson(response['body']);
    return profile;
  }

  Future<UserProfile> updateCommunicationPreferences(
    bool acceptedNewsletter,
  ) async {
    final response = await api.post(
      UPDATE_COMMUNICATIONS_PATH,
      {'acceptedNewsletter': acceptedNewsletter},
    );
    final profile = UserProfile.fromJson(response['body']);
    return profile;
  }
}
