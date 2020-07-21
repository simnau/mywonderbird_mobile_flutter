import 'dart:io';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:layout/locator.dart';
import 'package:layout/services/api.dart';
import 'package:layout/services/token.dart';

const REFRESH_TOKEN_PATH = '/api/auth/refresh';

class RefreshTokenRetryPolicy extends RetryPolicy {
  final maxRetryAttempts = 1;

  @override
  Future<bool> shouldAttemptRetryOnResponse(ResponseData response) async {
    if (response.statusCode == HttpStatus.unauthorized) {
      final api = locator<API>();
      final tokenService = locator<TokenService>();
      tokenService.clearAccessToken();
      final refreshToken = await tokenService.getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      final refreshResponse = await api.post(REFRESH_TOKEN_PATH, {
        'refreshToken': refreshToken,
      });
      final rawResponse = refreshResponse['response'];

      if (rawResponse.statusCode != HttpStatus.ok) {
        tokenService.clearRefreshToken();
        return false;
      }

      final accessToken = refreshResponse['body']['accessToken'];
      tokenService.setAccessToken(accessToken);

      return true;
    }

    return false;
  }
}
