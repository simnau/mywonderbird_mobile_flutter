import 'package:mywonderbird/constants/storage.dart';
import 'package:mywonderbird/services/storage.dart';

class OnboardingService {
  final StorageService storageService;

  OnboardingService({
    this.storageService,
  });

  Future<bool> hasCompletedOnboarding() async {
    return (await storageService.getBool(ONBOARDING_KEY)) ?? false;
  }

  Future<void> markCompletedOnboarding() async {
    storageService.setBool(ONBOARDING_KEY, true);
  }
}
