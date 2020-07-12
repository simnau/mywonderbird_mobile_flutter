import 'package:get_it/get_it.dart';
import 'package:layout/providers/journeys.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/services/api.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/journeys.dart';
import 'package:layout/services/location.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/services/profile.dart';
import 'package:layout/services/sharing.dart';
import 'package:layout/services/storage.dart';
import 'package:layout/services/token.dart';
import 'package:layout/sharing-intent.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  final storageService = StorageService();
  final tokenService = TokenService(storageService: storageService);
  final api = API(tokenService: tokenService);

  final profileService = ProfileService(
    api: api,
    tokenService: tokenService,
  );
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => storageService);
  locator.registerLazySingleton(() => api);
  locator.registerLazySingleton(() => profileService);
  locator.registerLazySingleton(() => tokenService);
  locator.registerLazySingleton(
    () => AuthenticationService(
      api: api,
      tokenService: tokenService,
      profileService: profileService,
    ),
  );
  locator.registerLazySingleton(() => LocationService(api: api));
  locator.registerLazySingleton(() => JourneyService(api: api));
  locator.registerLazySingleton(() => SharingService(api: api));

  // Providers
  locator.registerLazySingleton(() => JourneysProvider());
  locator.registerLazySingleton(() => SharePictureProvider());

  locator.registerLazySingleton(() => SharingIntent());
}
