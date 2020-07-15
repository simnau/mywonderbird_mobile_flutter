import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:layout/exceptions/authentication-exception.dart';
import 'package:layout/exceptions/unauthorized-exception.dart';
import 'package:layout/models/user-profile.dart';
import 'package:layout/models/user.dart';
import 'package:layout/services/api.dart';
import 'package:layout/services/profile.dart';
import 'package:layout/services/token.dart';

const SIGN_IN_PATH = '/api/auth/login';
const SIGN_UP_PATH = '/api/auth/register';
const ME_PATH = '/api/auth/me';
const CONFIRM_ACCOUNT_PATH = '/api/auth/confirm';
const CODE_PATH = '/api/auth/code';

class AuthenticationService {
  final StreamController<User> _userController = StreamController<User>();
  final TokenService tokenService;
  final ProfileService profileService;
  final API api;

  AuthenticationService({
    @required this.tokenService,
    @required this.profileService,
    @required this.api,
  });

  Stream<User> get userStream => _userController.stream;

  Future<User> signIn(String email, String password) async {
    final response = await api.post(
      SIGN_IN_PATH,
      {'email': email, 'password': password},
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode == HttpStatus.unauthorized) {
      await tokenService.clearTokens();
      return signIn(email, password);
    } else if (rawResponse.statusCode != HttpStatus.ok) {
      final errorCode = response['body']['code'];
      throw AuthenticationException(
        'Incorrect email/password',
        errorCode: errorCode,
      );
    }

    final body = response['body'];
    final accessToken = body['accessToken'];
    final refreshToken = body['refreshToken'];
    final userId = body['userId'];
    final role = body['role'];
    final provider = body['provider'];

    await tokenService.setAccessToken(accessToken);
    await tokenService.setRefreshToken(refreshToken);

    UserProfile profile = await profileService.getUserProfile();
    final user = User(
      id: userId,
      role: role,
      provider: provider,
      profile: profile,
    );
    _userController.add(user);

    return user;
  }

  signUp(email, password) async {
    final response = await api.post(
      SIGN_UP_PATH,
      {'email': email, 'password': password},
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception('We were unable to sign you up');
    }
  }

  Future<User> signOut() async {
    await tokenService.clearTokens();

    final user = null;
    _userController.add(user);

    return user;
  }

  Future<User> checkAuth() async {
    try {
      final user = await me();
      final profile = await profileService.getUserProfile();
      user.profile = profile;
      _userController.add(user);
      return user;
    } on UnauthorizedException {
      _userController.add(null);
      return null;
    }
  }

  Future<User> me() async {
    final response = await api.get(
      ME_PATH,
    );
    return User.fromJson(response['body']);
  }

  sendConfirmationCode(String email) async {
    final response = await api.post(
      CODE_PATH,
      {'email': email},
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new Exception('There was an error sending the code');
    }
  }

  confirmAccount(String email, String code) async {
    final response = await api.post(
      CONFIRM_ACCOUNT_PATH,
      {'email': email, 'code': code},
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new AuthenticationException('Invalid Code');
    }
  }
}
