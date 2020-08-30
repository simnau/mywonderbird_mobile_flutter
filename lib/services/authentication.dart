import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/exceptions/unauthorized-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/providers/terms.dart';
import 'package:mywonderbird/routes/authentication/select-auth-option.dart';
import 'package:mywonderbird/routes/home/main.dart';
import 'package:mywonderbird/routes/terms/main.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:mywonderbird/services/terms.dart';
import 'package:mywonderbird/services/token.dart';
import 'package:mywonderbird/types/terms-arguments.dart';

import 'navigation.dart';

const SIGN_IN_PATH = '/api/auth/login';
const SIGN_UP_PATH = '/api/auth/register';
const ME_PATH = '/api/auth/me';
const CONFIRM_ACCOUNT_PATH = '/api/auth/confirm';
const CODE_PATH = '/api/auth/code';
const FORGOT_PASSWORD_PATH = '/api/auth/forgot-password';
const RESET_PASSWORD_PATH = '/api/auth/reset-password';
const CHANGE_PASSWORD_PATH = '/api/auth/change-password';

class AuthenticationService {
  final StreamController<User> _userController = StreamController<User>();
  final TokenService tokenService;
  final ProfileService profileService;
  final TermsService termsService;
  final NavigationService navigationService;
  final TermsProvider termsProvider;
  final API api;

  AuthenticationService({
    @required this.tokenService,
    @required this.profileService,
    @required this.termsService,
    @required this.navigationService,
    @required this.termsProvider,
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
      throw new AuthenticationException(
        'We were unable to sign you up',
        errorCode: response['body']['code'],
      );
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

  addUser(User user) async {
    _userController.add(user);
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

  sendPasswordResetCode(String email) async {
    return api.post(
      FORGOT_PASSWORD_PATH,
      {'email': email},
    );
  }

  resetPassword(String email, String code, String password) async {
    return api.post(
      RESET_PASSWORD_PATH,
      {
        'email': email,
        'code': code,
        'password': password,
      },
    );
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

  changePassword(String currentPassword, String newPassword) async {
    final response = await api.post(
      CHANGE_PASSWORD_PATH,
      {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new AuthenticationException('Unable to change the password');
    }
  }

  afterSignIn(User user) {
    if (user != null) {
      _handleTerms(user.profile?.acceptedTermsAt);
    }
  }

  onStartup(User user) async {
    navigationService.popUntil((route) => route.isFirst);
    if (user != null) {
      _handleTerms(user.profile?.acceptedTermsAt);
    } else {
      await navigationService.pushReplacementNamed(SelectAuthOption.PATH);
    }
  }

  _handleTerms(acceptedTermsAt) async {
    final terms = await locator<TermsService>().fetchTermsByType();
    final termsOfService = terms['termsOfService'];
    final privacyPolicy = terms['privacyPolicy'];
    termsProvider.termsOfService = termsOfService;
    termsProvider.privacyPolicy = privacyPolicy;

    if (acceptedTermsAt == null) {
      _navigateToTerms(false);
    } else if (!termsService.areTermsUpToDate(
      acceptedTermsAt,
      termsOfService,
      privacyPolicy,
    )) {
      _navigateToTerms(true);
    } else {
      _navigateToHome();
    }
  }

  _navigateToHome() async {
    await navigationService.pushReplacementNamed(HomePage.PATH);
  }

  _navigateToTerms(bool isUpdate) async {
    await navigationService.pushReplacementNamed(
      TermsPage.PATH,
      arguments: TermsArguments(
        isUpdate: isUpdate,
      ),
    );
  }
}
