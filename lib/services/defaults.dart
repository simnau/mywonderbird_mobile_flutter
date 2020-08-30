import 'package:mywonderbird/constants/storage.dart';
import 'package:mywonderbird/services/storage.dart';

class DefaultsService {
  final StorageService storageService;

  DefaultsService({
    this.storageService,
  });

  reset() async {
    for (final key in RESETABLE_KEYS) {
      await storageService.removeKey(key);
    }
  }
}
