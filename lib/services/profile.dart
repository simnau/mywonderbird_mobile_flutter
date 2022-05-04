import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/services/token.dart';

const PROFILE_PATH = '/api/profile';
const PROFILE_V2_PATH = "$PROFILE_PATH/v2";
final profileByIdPath = (id) => "$PROFILE_PATH/$id";
const UPDATE_COMMUNICATIONS_PATH = "$PROFILE_PATH/communication";
const UPDATE_AVATAR_PATH = "$PROFILE_PATH/avatar";

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
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        "There was an error fetching the user profile. Cause: ${rawResponse?.reasonPhrase}",
      );
    }

    final profile = UserProfile.fromJson(response['body']);
    return profile;
  }

  Future<User> getUserById(String id) async {
    final response = await api.get(
      profileByIdPath(id),
    );
    final profile = UserProfile.fromJson(response['body']);
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        "There was an error fetching the user with id $id profile. Cause: ${rawResponse?.reasonPhrase}",
      );
    }

    return User(
      id: id,
      profile: profile,
    );
  }

  Future<UserProfile> updateUserProfile(
    UserProfile userProfileUpdate,
    List<int> avatarBytes,
  ) async {
    final filename = 'avatar.png';
    final List<http.MultipartFile> files = [];

    if (avatarBytes != null) {
      files.add(
        http.MultipartFile.fromBytes(
          filename,
          avatarBytes,
          filename: filename,
        ),
      );
    }
    final response = await api.postMultipartFiles(
      PROFILE_V2_PATH,
      files,
      fields: userProfileUpdate.toFieldData(),
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        "There was an error updating the user profile. Cause: ${rawResponse?.reasonPhrase}",
      );
    }

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
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception(
        "There was an error updating the user communication preferences. Cause: ${rawResponse?.reasonPhrase}",
      );
    }

    final profile = UserProfile.fromJson(response['body']);
    return profile;
  }
}
