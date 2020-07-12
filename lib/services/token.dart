import 'package:flutter/material.dart';
import 'package:layout/constants/storage.dart';
import 'package:layout/services/storage.dart';

class TokenService {
  final StorageService storageService;

  TokenService({@required this.storageService});

  clearTokens() async {
    await storageService.removeKey(ACCESS_TOKEN_KEY);
    await storageService.removeKey(REFRESH_TOKEN_KEY);
  }

  setAccessToken(String accessToken) async {
    await storageService.setString(ACCESS_TOKEN_KEY, accessToken);
  }

  setRefreshToken(String refreshToken) async {
    await storageService.setString(REFRESH_TOKEN_KEY, refreshToken);
  }

  Future<String> getAccessToken() async {
    return storageService.getString(ACCESS_TOKEN_KEY);
  }

  Future<String> getRefreshToken() async {
    return storageService.getString(REFRESH_TOKEN_KEY);
  }
}
