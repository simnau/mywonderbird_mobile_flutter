import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:layout/constants/storage.dart';
import 'package:layout/exceptions/authentication-exception.dart';
import 'package:layout/models/user.dart';
import 'package:layout/services/api.dart';
import 'package:layout/services/storage.dart';

const signInPath = '/api/auth/login';

class AuthenticationService {
  StreamController<User> _userController = StreamController<User>();
  StorageService storageService;
  API api;

  AuthenticationService({
    @required this.storageService,
    @required this.api,
  });

  Stream<User> get userStream => _userController.stream;

  Future<User> signIn(String email, String password) async {
    final response = await api.post(
      signInPath,
      {'email': email, 'password': password},
    );
    Response rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw AuthenticationException('Incorrect email/password');
    }
    final accessToken = response['body']['accessToken'];
    final refreshToken = response['body']['refreshToken'];

    await storageService.setString(ACCESS_TOKEN_KEY, accessToken);
    await storageService.setString(REFRESH_TOKEN_KEY, refreshToken);

    // final user = User(id: 1);
    // _userController.add(user);

    // return user;
  }

  Future<User> signOut() async {
    final user = null;
    _userController.add(user);

    return user;
  }

  Future<User> checkAuth() async {
    final user = User(id: 1);
    // _userController.add(user);
    // return user;
    return null;
  }
}
