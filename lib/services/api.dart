import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_client_with_interceptor.dart';
import 'package:layout/exceptions/unauthorized-exception.dart';
import 'package:layout/http/authentication.dart';
import 'package:layout/http/retry-policy.dart';
import 'package:layout/routes/authentication/select-auth-option.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/services/token.dart';

final apiBase = DotEnv().env['API_BASE'];

class API {
  TokenService tokenService;
  NavigationService navigationService;
  http.Client client;

  API({
    @required TokenService tokenService,
    @required NavigationService navigationService,
    @required AuthenticationInterceptor authenticationInterceptor,
  }) {
    this.tokenService = tokenService;
    this.navigationService = navigationService;
    client = HttpClientWithInterceptor.build(
      interceptors: [
        authenticationInterceptor,
      ],
      retryPolicy: RefreshTokenRetryPolicy(),
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String> params,
    Map<String, String> headers,
  }) async {
    final uri = _createUri(apiBase, path, params);
    final response = await client.get(uri, headers: headers);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, dynamic> params,
    Map<String, String> headers,
  }) async {
    final uri = _createUri(apiBase, path, params);
    final fullHeaders = _jsonHeaders(headers);

    final response = await client.post(
      uri,
      headers: fullHeaders,
      body: json.encode(body),
    );

    return _handleResponse(response);
  }

  Uri _createUri(String base, String path, Map<String, dynamic> params) {
    final parsedUri = Uri.parse(base);
    if (parsedUri.scheme == 'http') {
      return Uri.http(parsedUri.authority, path, params);
    } else if (parsedUri.scheme == 'https') {
      return Uri.https(parsedUri.authority, path, params);
    }

    return null;
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
