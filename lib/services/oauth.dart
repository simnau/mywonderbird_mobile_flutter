import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/oauth.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:mywonderbird/services/token.dart';

const AUTHORIZATION_URL_PATH = '/api/oauth/authorize-url';
const OAUTH_SIGN_IN_PATH = '/api/oauth/login';

class OAuthService {
  final API api;
  final TokenService tokenService;
  final ProfileService profileService;
  final AuthenticationService authenticationService;

  OAuthService({
    @required this.api,
    @required this.tokenService,
    @required this.profileService,
    @required this.authenticationService,
  });

  Future<String> getAuthorizationUrl() async {
    final response = await api.get(
      AUTHORIZATION_URL_PATH,
    );
    return response['body']['authorizeUrl'];
  }

  Future<User> fblogin(String code) async {
    final params = Map<String, String>.from({
      'code': code,
      'redirectUri': FB_SIGN_IN_REDIRECT_URL,
    });
    final response = await api.get(
      OAUTH_SIGN_IN_PATH,
      params: params,
    );

    return _handleAuthResponse(response);
  }

  Future<User> glogin(String code) async {
    final params = Map<String, String>.from({
      'code': code,
      'redirectUri': GOOGLE_SIGN_IN_REDIRECT_URL,
    });
    final response = await api.get(
      OAUTH_SIGN_IN_PATH,
      params: params,
    );

    return _handleAuthResponse(response);
  }

  Future<User> _handleAuthResponse(response) async {
    final rawResponse = response['response'];
    final body = response['body'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw AuthenticationException(
        body['error'],
        errorCode: body['code'],
      );
    }

    final accessToken = body['accessToken'];
    final refreshToken = body['refreshToken'];

    await tokenService.setAccessToken(accessToken);
    await tokenService.setRefreshToken(refreshToken);

    return authenticationService.checkAuth();
  }
}
