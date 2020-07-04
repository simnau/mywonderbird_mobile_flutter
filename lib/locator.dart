import 'package:get_it/get_it.dart';
import 'package:layout/providers/journeys.dart';
import 'package:layout/providers/share-picture.dart';
import 'package:layout/services/api.dart';
import 'package:layout/services/authentication.dart';
import 'package:layout/services/location.dart';
import 'package:layout/services/navigation.dart';
import 'package:layout/services/storage.dart';
import 'package:layout/sharing-intent.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  final storageService = StorageService();
  final api = API(storageService: storageService);

  locator.registerLazySingleton(() => api);
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(
    () => AuthenticationService(
      api: api,
      storageService: storageService,
    ),
  );
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => StorageService());

  // Providers
  locator.registerLazySingleton(() => JourneysProvider());
  locator.registerLazySingleton(() => SharePictureProvider());

  locator.registerLazySingleton(() => SharingIntent());
}
