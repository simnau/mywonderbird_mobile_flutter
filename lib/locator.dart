import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:get_it/get_it.dart';
import 'package:mywonderbird/deep-links.dart';
import 'package:mywonderbird/http/retry-policy.dart';
import 'package:mywonderbird/providers/journey.dart';
import 'package:mywonderbird/providers/journeys.dart';
import 'package:mywonderbird/providers/oauth.dart';
import 'package:mywonderbird/providers/questionnaire.dart';
import 'package:mywonderbird/providers/saved-trips.dart';
import 'package:mywonderbird/providers/share-picture.dart';
import 'package:mywonderbird/providers/swipe-filters.dart';
import 'package:mywonderbird/providers/swipe.dart';
import 'package:mywonderbird/providers/tags.dart';
import 'package:mywonderbird/providers/terms.dart';
import 'package:mywonderbird/services/api.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/bookmark-group.dart';
import 'package:mywonderbird/services/bookmark.dart';
import 'package:mywonderbird/services/country.dart';
import 'package:mywonderbird/services/defaults.dart';
import 'package:mywonderbird/services/feed.dart';
import 'package:mywonderbird/services/feedback.dart';
import 'package:mywonderbird/services/journeys.dart';
import 'package:mywonderbird/services/like.dart';
import 'package:mywonderbird/services/geo.dart';
import 'package:mywonderbird/services/system-location.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/oauth.dart';
import 'package:mywonderbird/services/onboarding.dart';
import 'package:mywonderbird/services/picture-data.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:mywonderbird/services/saved-trip.dart';
import 'package:mywonderbird/services/search.dart';
import 'package:mywonderbird/services/sharing.dart';
import 'package:mywonderbird/services/storage.dart';
import 'package:mywonderbird/services/suggestion.dart';
import 'package:mywonderbird/services/tag.dart';
import 'package:mywonderbird/services/terms.dart';
import 'package:mywonderbird/services/token.dart';
import 'package:mywonderbird/services/user-location.dart';
import 'package:mywonderbird/sharing-intent.dart';
import 'package:mywonderbird/util/converters/suggested-location.dart';

GetIt locator = GetIt.instance;

setupLocator({String env}) {
  final storageService = StorageService();
  final termsProvider = TermsProvider();
  final tokenService = TokenService(storageService: storageService);
  final navigationService = NavigationService();
  final retryPolicy = RefreshTokenRetryPolicy();
  final api = API(
    tokenService: tokenService,
    navigationService: navigationService,
    retryPolicy: retryPolicy,
  );
  final termsService = TermsService(api: api);
  final geoService = GeoService(api: api);

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
  FirebaseAnalytics analytics = FirebaseAnalytics();
  FirebaseAnalyticsObserver analyticsObserver =
      FirebaseAnalyticsObserver(analytics: analytics);

  // Services
  locator.registerLazySingleton(() => navigationService);
  locator.registerLazySingleton(() => storageService);
  locator.registerLazySingleton(() => api);
  locator.registerLazySingleton(() => profileService);
  locator.registerLazySingleton(() => tokenService);
  locator.registerLazySingleton(() => authenticationService);
  locator.registerLazySingleton(() => termsService);
  locator.registerLazySingleton(() => geoService);
  locator.registerLazySingleton(() => JourneyService(api: api));
  locator.registerLazySingleton(() => UserLocationService(api: api));
  locator.registerLazySingleton(() => SystemLocationService(api: api));
  locator.registerLazySingleton(() => SharingService(api: api));
  locator.registerLazySingleton(() => FeedService(api: api));
  locator.registerLazySingleton(() => LikeService(api: api));
  locator.registerLazySingleton(() => BookmarkService(api: api));
  locator.registerLazySingleton(() => BookmarkGroupService(api: api));
  locator.registerLazySingleton(() => SuggestionService(api: api));
  locator.registerLazySingleton(() => CountryService(api: api));
  locator.registerLazySingleton(() => SavedTripService(api: api));
  locator.registerLazySingleton(() => SearchService(api: api));
  locator.registerLazySingleton(() => TagService(api: api));
  locator.registerLazySingleton(() => FeedbackService(api: api));
  locator.registerLazySingleton(
    () => DefaultsService(
      storageService: storageService,
    ),
  );
  locator.registerLazySingleton(
    () => OnboardingService(storageService: storageService),
  );
  locator.registerLazySingleton(
    () => PictureDataService(locationService: geoService),
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
  locator.registerLazySingleton(() => TagsProvider());
  locator.registerLazySingleton(() => QuestionnaireProvider());
  locator.registerLazySingleton(() => SavedTripsProvider());
  locator.registerLazySingleton(() => termsProvider);
  locator.registerLazySingleton(() => SwipeProvider());
  locator.registerLazySingleton(() => SwipeFiltersProvider());

  // Other
  locator.registerLazySingleton(() => DeepLinks());
  locator.registerLazySingleton(() => SharingIntent());
  locator.registerLazySingleton(() => retryPolicy);
  locator.registerLazySingleton(() => analytics);
  locator.registerLazySingleton(() => analyticsObserver);
  locator.registerLazySingleton(() => SuggestedLocationConverter());
}
