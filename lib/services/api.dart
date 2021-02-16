import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mywonderbird/constants/auth.dart';
import 'package:mywonderbird/exceptions/unauthorized-exception.dart';
import 'package:mywonderbird/http/retry-policy.dart';
import 'package:mywonderbird/routes/authentication/select-auth-option.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/token.dart';

final apiBase = 'https://api.mywonderbird.com';

class API {
  TokenService tokenService;
  NavigationService navigationService;
  http.Client client;
  RefreshTokenRetryPolicy retryPolicy;

  API({
    @required TokenService tokenService,
    @required NavigationService navigationService,
    @required RefreshTokenRetryPolicy retryPolicy,
  }) {
    this.tokenService = tokenService;
    this.navigationService = navigationService;
    this.retryPolicy = retryPolicy;
    this.client = http.Client();
  }

  Future<Map<String, String>> get authenticationHeaders async {
    final accessToken = await tokenService.getAccessToken();

    if (accessToken == null) {
      return {};
    }

    return {
      HttpHeaders.authorizationHeader: accessToken,
    };
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic> params,
    Map<String, String> headers = const {},
    int retryCount = 0,
    bool noRetry = false,
  }) async {
    final uri = _createUri(apiBase, path, params);
    final response = await client.get(uri, headers: {
      ...headers,
      ...await authenticationHeaders,
    });

    if (!noRetry) {
      final shouldRetry =
          await retryPolicy.shouldAttemptRetryOnResponse(response);

      if (retryCount < retryPolicy.maxRetryAttempts && shouldRetry) {
        return get(
          path,
          params: params,
          headers: {
            ...headers,
            ...await authenticationHeaders,
          },
          retryCount: retryCount + 1,
        );
      }
    }

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String> params,
    Map<String, String> headers = const {},
    int retryCount = 0,
    bool noRetry = false,
  }) async {
    final uri = _createUri(apiBase, path, params);
    final response = await client.delete(uri, headers: {
      ...headers,
      ...await authenticationHeaders,
    });

    if (!noRetry) {
      final shouldRetry =
          await retryPolicy.shouldAttemptRetryOnResponse(response);

      if (retryCount < retryPolicy.maxRetryAttempts && shouldRetry) {
        return delete(
          path,
          params: params,
          headers: {
            ...headers,
            ...await authenticationHeaders,
          },
          retryCount: retryCount + 1,
        );
      }
    }

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, dynamic> params,
    Map<String, String> headers = const {},
    int retryCount = 0,
    bool noRetry = false,
  }) async {
    final uri = _createUri(apiBase, path, params);
    final fullHeaders = _jsonHeaders(headers);

    final response = await client.post(
      uri,
      headers: {
        ...fullHeaders,
        ...await authenticationHeaders,
      },
      body: json.encode(body),
    );

    if (!noRetry) {
      final shouldRetry =
          await retryPolicy.shouldAttemptRetryOnResponse(response);

      if (retryCount < retryPolicy.maxRetryAttempts && shouldRetry) {
        return post(
          path,
          body,
          params: params,
          headers: {
            ...headers,
            ...await authenticationHeaders,
          },
          retryCount: retryCount + 1,
        );
      }
    }

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postMultipartFiles(
    String path,
    List<MultipartFile> files, {
    Map<String, String> fields,
    Map<String, dynamic> params,
    Map<String, String> headers = const {},
    int retryCount = 0,
    bool noRetry = false,
  }) async {
    final uri = _createUri(apiBase, path, params);
    final request = http.MultipartRequest(
      'POST',
      uri,
    );
    request.files.addAll(files);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    final accessToken = await tokenService.getAccessToken();

    if (accessToken != null) {
      request.headers[AUTHORIZATION_HEADER] = accessToken;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (!noRetry) {
      final shouldRetry =
          await retryPolicy.shouldAttemptRetryOnResponse(response);

      if (retryCount < retryPolicy.maxRetryAttempts && shouldRetry) {
        return postMultipartFiles(
          path,
          files,
          params: params,
          headers: {
            ...headers,
            ...await authenticationHeaders,
          },
          retryCount: retryCount + 1,
        );
      }
    }

    return _handleResponse(response);
  }

  Uri _createUri(String base, String path, Map<String, dynamic> params) {
    final parsedUri = Uri.parse(base);

    final uri = Uri(
      scheme: parsedUri.scheme,
      host: parsedUri.host,
      port: parsedUri.port,
      path: path,
      queryParameters: params,
    );

    return uri;
  }

  Map<String, String> _jsonHeaders(
    Map<String, String> baseHeaders,
  ) {
    return {
      ...(baseHeaders ?? {}),
      'content-type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == HttpStatus.unauthorized) {
      await tokenService.clearTokens();
      _navigateToAuth();
      throw UnauthorizedException('The user is not authorized');
    }

    final responseBody = json.decode(response.body);

    return {
      'response': response,
      'body': responseBody,
    };
  }

  _navigateToAuth() async {
    navigationService.popUntil((route) => route.isFirst);
    navigationService.pushReplacementNamed(SelectAuthOption.PATH);
  }
}
