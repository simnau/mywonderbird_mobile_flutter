import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:layout/deep-links.dart';
import 'package:layout/http/authentication.dart';
import 'package:layout/http/retry-policy.dart';
import 'package:layout/providers/journeys.dart';
import 'package:layout/providers/oauth.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/providers/terms.dart';
import 'package:layout/services/api.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/feed.dart';
import 'package:layout/services/journeys.dart';
import 'package:layout/services/like.dart';
import 'package:layout/services/location.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/services/oauth.dart';
import 'package:layout/services/picture-data.dart';
import 'package:layout/services/profile.dart';
import 'package:layout/services/sharing.dart';
import 'package:layout/services/storage.dart';
import 'package:layout/services/terms.dart';
import 'package:layout/services/token.dart';
import 'package:layout/sharing-intent.dart';
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
  locator.registerLazySingleton(
      () => PictureDataService(locationService: locationService));
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
