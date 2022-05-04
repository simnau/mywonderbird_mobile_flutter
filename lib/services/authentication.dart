import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mywonderbird/constants/error-codes.dart';
import 'package:mywonderbird/exceptions/authentication-exception.dart';
import 'package:mywonderbird/exceptions/unauthorized-exception.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/providers/sharing-intent.dart';
import 'package:mywonderbird/providers/terms.dart';
import 'package:mywonderbird/routes/authentication/select-auth-option.dart';
import 'package:mywonderbird/routes/home/main.dart';
import 'package:mywonderbird/routes/terms/main.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:mywonderbird/services/push-notifications.dart';
import 'package:mywonderbird/services/terms.dart';
import 'package:mywonderbird/services/token.dart';
import 'package:mywonderbird/types/terms-arguments.dart';
import 'package:mywonderbird/util/sentry.dart';

import 'navigation.dart';

const SIGN_IN_PATH = '/api/auth/login';
const SIGN_UP_PATH = '/api/auth/register';
const ME_PATH = '/api/auth/me';
const CONFIRM_ACCOUNT_PATH = '/api/auth/confirm';
const CODE_PATH = '/api/auth/code';
const FORGOT_PASSWORD_PATH = '/api/auth/forgot-password';
const RESET_PASSWORD_PATH = '/api/auth/reset-password';
const CHANGE_PASSWORD_PATH = '/api/auth/change-password';

const USER_ID_KEY = 'sub';
const ROLE_KEY = 'custom:role';

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

  signIn(String email, String password) async {
    try {
      final credentials = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final analytics = locator<FirebaseAnalytics>();
      await analytics.logLogin(loginMethod: "email+password");

      return credentials;
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw new AuthenticationException(
          'Invalid password / email combination',
          errorCode: INVALID_CREDENTIALS,
        );
      } else if (e.code == 'too-many-requests') {
        throw new AuthenticationException(
          'You made too many attempts to sign in. Try again later',
          errorCode: TOO_MANY_ATTEMPTS,
        );
      } else {
        throw new AuthenticationException(
          'There was an error signing you in',
          errorCode: UNKNOWN_ERROR,
        );
      }
    } catch (e) {
      throw new AuthenticationException(
        'There was an error signing you in',
        errorCode: UNKNOWN_ERROR,
      );
    }
  }

  signUp(email, password) async {
    try {
      await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw new AuthenticationException(
          'The password provided is too weak',
          errorCode: WEAK_PASSWORD,
        );
      } else if (e.code == 'email-already-in-use') {
        throw new AuthenticationException(
          'The account already exists for this email',
          errorCode: USERNAME_EXISTS,
        );
      }
    } catch (e) {
      throw new AuthenticationException(
        'We were unable to sign you up',
        errorCode: UNKNOWN_ERROR,
      );
    }

    final analytics = locator<FirebaseAnalytics>();
    analytics.logSignUp(signUpMethod: 'email_password');
  }

  signOut() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.disconnect();
    } catch (e) {
      // TODO: should only disconnect if signed in with google
    }

    final deviceToken = await FirebaseMessaging.instance.getToken();
    final pushNotificationService = locator<PushNotificationService>();
    await pushNotificationService.deleteUserDeviceToken(deviceToken);

    await auth.FirebaseAuth.instance.signOut();

    final analytics = locator<FirebaseAnalytics>();
    analytics.setUserId(id: null);
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
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);
      throw error;
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

  sendPasswordResetEmail(String email) async {
    return auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  resetPassword(String email, String code, String password) async {
    final response = await api.post(
      RESET_PASSWORD_PATH,
      {
        'email': email,
        'code': code,
        'password': password,
      },
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new AuthenticationException(
        'There was an error resetting the password',
        errorCode: response['body']['code'],
      );
    }
  }

  confirmAccount(String email, String code) async {
    final response = await api.post(
      CONFIRM_ACCOUNT_PATH,
      {'email': email, 'code': code},
    );
    final rawResponse = response['response'];

    if (rawResponse.statusCode != HttpStatus.ok) {
      throw new AuthenticationException(
        'Invalid Code',
        errorCode: response['body']['code'],
      );
    }
  }

  changePassword(String currentPassword, String newPassword) async {
    try {
      final user = auth.FirebaseAuth.instance.currentUser;

      final emailPasswordCredentials = auth.EmailAuthProvider.credential(
        email: user.email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(emailPasswordCredentials);
      await user.updatePassword(newPassword);
    } catch (e) {
      String errorCode;

      switch (e.code) {
        case 'wrong-password':
          errorCode = NOT_AUTHORIZED;
          break;
        default:
          errorCode = UNKNOWN_ERROR;
          break;
      }

      throw new AuthenticationException(
        'Unable to change the password',
        errorCode: errorCode,
      );
    }
  }

  afterSignIn(User user) async {
    if (user != null) {
      _handleTerms(user.profile?.acceptedTermsAt);

      final deviceToken = await FirebaseMessaging.instance.getToken();
      final pushNotificationService = locator<PushNotificationService>();
      await pushNotificationService.saveUserDeviceToken(deviceToken);
    }

    final analytics = locator<FirebaseAnalytics>();
    analytics.setUserId(id: user?.id);
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
    final sharingIntentProvider = locator<SharingIntentProvider>();

    navigationService.pushReplacementNamed(HomePage.PATH);
    sharingIntentProvider.applicationLoadComplete = true;

    if (sharingIntentProvider.sharedImagePaths != null) {
      sharingIntentProvider.handleShareImages(
        sharingIntentProvider.sharedImagePaths,
      );
      sharingIntentProvider.sharedImagePaths = null;
    }
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
