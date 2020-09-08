import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:mywonderbird/deep-links.dart';
import 'package:mywonderbird/http/authentication.dart';
import 'package:mywonderbird/http/retry-policy.dart';
import 'package:mywonderbird/providers/journey.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:mywonderbird/providers/oauth.dart';
import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/providers/terms.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/bookmark-group.dart';
import 'package:mywonderbird/services/bookmark.dart';
import 'package:mywonderbird/services/defaults.dart';
import 'package:mywonderbird/services/feed.dart';
import 'package:mywonderbird/services/journeys.dart';
import 'package:mywonderbird/services/like.dart';
import 'package:mywonderbird/services/location.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/oauth.dart';
import 'package:mywonderbird/services/onboarding.dart';
import 'package:mywonderbird/services/picture-data.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:mywonderbird/services/sharing.dart';
import 'package:mywonderbird/services/storage.dart';
import 'package:mywonderbird/services/suggestion.dart';
import 'package:mywonderbird/services/terms.dart';
import 'package:mywonderbird/services/token.dart';
import 'package:mywonderbird/sharing-intent.dart';
import 'package:sentry/sentry.dart';

GetIt locator = GetIt.instance;

final sentryDSN = DotEnv().env['SENTRY_DSN'];

setupLocator({String env}) {
  final storageService = StorageService();
  final termsProvider = TermsProvider();
  final tokenService = TokenService(storageService: storageService);
  final navigationService = NavigationService();
  final authenticationInterceptor = AuthenticationInterceptor(
    tokenService: tokenService,
  );
  final retryPolicy = RefreshTokenRetryPolicy();
  final api = API(
    tokenService: tokenService,
    navigationService: navigationService,
    authenticationInterceptor: authenticationInterceptor,
    retryPolicy: retryPolicy,
  );
  final termsService = TermsService(api: api);
  final locationService = LocationService(api: api);

  final profileService = ProfileService(
    api: api,
    tokenService: tokenService,
  );
  final authenticationService = AuthenticationService(
    api: api,
    termsProvider: termsProvider,
    tokenService: tokenService,
    profileService: profileService,
    termsService: termsService,
    navigationService: navigationService,
  );

  // Services
  locator.registerLazySingleton(() => navigationService);
  locator.registerLazySingleton(() => storageService);
  locator.registerLazySingleton(() => api);
  locator.registerLazySingleton(() => profileService);
  locator.registerLazySingleton(() => tokenService);
  locator.registerLazySingleton(() => authenticationService);
  locator.registerLazySingleton(() => termsService);
  locator.registerLazySingleton(() => locationService);
  locator.registerLazySingleton(() => JourneyService(api: api));
  locator.registerLazySingleton(() => SharingService(api: api));
  locator.registerLazySingleton(() => FeedService(api: api));
  locator.registerLazySingleton(() => LikeService(api: api));
  locator.registerLazySingleton(() => BookmarkService(api: api));
  locator.registerLazySingleton(() => BookmarkGroupService(api: api));
  locator.registerLazySingleton(() => SuggestionService(api: api));
  locator.registerLazySingleton(
    () => DefaultsService(
      storageService: storageService,
    ),
  );
  locator.registerLazySingleton(
    () => OnboardingService(storageService: storageService),
  );
  locator.registerLazySingleton(
    () => PictureDataService(locationService: locationService),
  );
  locator.registerLazySingleton(
    () => OAuthService(
      api: api,
      profileService: profileService,
      tokenService: tokenService,
      authenticationService: authenticationService,
    ),
  );

  // Providers
  locator.registerLazySingleton(() => JourneysProvider());
  locator.registerLazySingleton(() => JourneyProvider());
  locator.registerLazySingleton(() => SharePictureProvider());
  locator.registerLazySingleton(() => OAuthProvider());
  locator.registerLazySingleton(() => termsProvider);

  // Other
  locator.registerLazySingleton(() => DeepLinks());
  locator.registerLazySingleton(() => SharingIntent());
  locator.registerLazySingleton(() => authenticationInterceptor);
  locator.registerLazySingleton(() => retryPolicy);

  SentryClient sentryClient =
      env == 'prod' ? SentryClient(dsn: sentryDSN) : null;
  locator.registerLazySingleton(() => sentryClient);
}
