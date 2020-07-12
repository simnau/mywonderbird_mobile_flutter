import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:layout/constants/auth.dart';
import 'package:layout/exceptions/unauthorized-exception.dart';
import 'package:layout/services/token.dart';

final apiBase = DotEnv().env['API_BASE'];

class API {
  TokenService tokenService;

  API({@required this.tokenService});

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String> params,
    Map<String, String> headers,
  }) async {
    final uri = _createUri(apiBase, path, params);
    final fullHeaders = await _createHeaders(headers);
    final response = await http.get(uri, headers: fullHeaders);

    if (response.statusCode == HttpStatus.unauthorized) {
      await tokenService.clearTokens();
      throw UnauthorizedException('The user is not authorized');
    }

    final responseBody = json.decode(response.body);

    return {
      'response': response,
      'body': responseBody,
    };
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, dynamic> params,
    Map<String, String> headers,
  }) async {
    final uri = _createUri(apiBase, path, params);
    final fullHeaders = await _createHeaders(_jsonHeaders(headers));

    final response = await http.post(
      uri,
      headers: fullHeaders,
      body: json.encode(body),
    );

    if (response.statusCode == HttpStatus.unauthorized) {
      await tokenService.clearTokens();
      throw UnauthorizedException('The user is not authorized');
    }

    final responseBody = json.decode(response.body);

    return {
      'response': response,
      'body': responseBody,
    };
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

  Future<Map<String, String>> _createHeaders(
    Map<String, String> baseHeaders,
  ) async {
    final accessToken = await tokenService.getAccessToken();

    if (accessToken != null) {
      return {
        ...(baseHeaders ?? {}),
        AUTHORIZATION_HEADER: accessToken,
      };
    }

    return baseHeaders;
  }
}
