import 'dart:io';

import 'package:http/http.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/services/token.dart';

const REFRESH_TOKEN_PATH = '/api/auth/refresh';

class RefreshTokenRetryPolicy {
  final maxRetryAttempts = 1;

  Future<bool> shouldAttemptRetryOnResponse(Response response) async {
    if (response.statusCode == HttpStatus.unauthorized) {
      final api = locator<API>();
      final tokenService = locator<TokenService>();
      tokenService.clearAccessToken();
      final refreshToken = await tokenService.getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      final refreshResponse = await api.post(
        REFRESH_TOKEN_PATH,
        {
          'refreshToken': refreshToken,
        },
        noRetry: true,
      );
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
