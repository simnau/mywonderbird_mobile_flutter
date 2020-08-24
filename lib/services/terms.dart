import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/models/terms.dart';
import 'package:mywonderbird/services/api.dart';

const TERMS_PATH = '/api/terms/latest';
const ACCEPT_TERMS_PATH = '/api/profile/terms';

class TermsService {
  final API api;

  TermsService({
    @required this.api,
  });

  bool areTermsUpToDate(
    DateTime acceptedTermsAt,
    Terms termsOfService,
    Terms privacyPolicy,
  ) {
    if (termsOfService == null && privacyPolicy == null) {
      return true;
    }

    if (acceptedTermsAt == null) {
      return false;
    }

    if (termsOfService != null &&
        termsOfService.updatedAt.isAfter(acceptedTermsAt)) {
      return false;
    }

    if (privacyPolicy != null &&
        privacyPolicy.updatedAt.isAfter(acceptedTermsAt)) {
      return false;
    }

    return true;
  }

  Future<Map<String, Terms>> fetchTermsByType() async {
    final response = await api.get(
      TERMS_PATH,
    );

    final body = response['body'];
    final termsOfService = body['termsOfService'];
    final privacyPolicy = body['privacyPolicy'];

    return {
      'termsOfService':
          termsOfService != null ? Terms.fromJson(termsOfService) : null,
      'privacyPolicy':
          privacyPolicy != null ? Terms.fromJson(privacyPolicy) : null,
    };
  }

  acceptTerms(bool acceptedTerms, {bool acceptedNewsletter}) async {
    final body = acceptedNewsletter != null
        ? {
            'acceptedTerms': acceptedTerms,
            'acceptedNewsletter': acceptedNewsletter,
          }
        : {
            'acceptedTerms': acceptedTerms,
          };

    final response = await api.post(
      ACCEPT_TERMS_PATH,
      body,
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw Exception(
          'There was an error saving the terms. Please try again later.');
    }
  }
}
