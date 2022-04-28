import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:mywonderbird/deep-links.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/providers/sharing-intent.dart';
import 'package:mywonderbird/routes.dart';
import 'package:mywonderbird/routes/authentication/select-auth-option.dart';
import 'package:mywonderbird/routes/notifications/main.dart';
import 'package:mywonderbird/routes/onboarding/main.dart';
import 'package:mywonderbird/routes/splash/main.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/onboarding.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:mywonderbird/sharing-intent.dart';
import 'package:mywonderbird/theme/style.dart';

class App extends StatefulWidget {
  final String initialRoute;

  const App({
    Key key,
    this.initialRoute,
  }) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final sharingIntentProvider = locator<SharingIntentProvider>();

  String initialRoute;

  @override
  void initState() {
    super.initState();
    initialRoute = widget.initialRoute ?? SplashScreen.PATH;
    sharingIntentProvider.addListener(_handleSharingProviderChange);

    _onStartup();
  }

  @override
  void dispose() {
    locator<DeepLinks>().dispose();
    locator<SharingIntent>().dispose();
    sharingIntentProvider.removeListener(_handleSharingProviderChange);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsObserver = locator<FirebaseAnalyticsObserver>();
    final routeObserver = locator<RouteObserver<ModalRoute<void>>>();

    return FeatureDiscovery(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyWonderbird',
        initialRoute: initialRoute,
        navigatorKey: locator<NavigationService>().navigatorKey,
        theme: appTheme,
        onGenerateRoute: generateRoute,
        navigatorObservers: [
          analyticsObserver,
          routeObserver,
        ],
      ),
    );
  }

  _onStartup() async {
    auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((auth.User user) async {
      final onboardingService = locator<OnboardingService>();
      final completedOnboarding =
          await onboardingService.hasCompletedOnboarding();

      if (!completedOnboarding) {
        final navigationService = locator<NavigationService>();

        await navigationService.pushReplacement(
          MaterialPageRoute(
            builder: (context) => Onboarding(
              callback: () => _onAfterOnboarding(user),
            ),
          ),
        );
      } else {
        _onAfterOnboarding(user);
      }
    });

    await _initListeners();
  }

  _initListeners() async {
    locator<DeepLinks>().setupDeepLinkListeners();
    locator<SharingIntent>().setupSharingIntentListeners();
  }

  _onAfterOnboarding(user) async {
    final authenticationService = locator<AuthenticationService>();
    final navigationService = locator<NavigationService>();

    if (user == null) {
      authenticationService.addUser(null);
      await navigationService.pushReplacementNamed(SelectAuthOption.PATH);
    } else {
      final profileService = locator<ProfileService>();
      final profile = await profileService.getUserProfile();
      final providers = user.providerData
          .map<String>(
            (p) => p.providerId?.toString(),
          )
          .toList();

      final appUser = User(
        id: user.uid,
        role: profile.role,
        providers: providers,
        profile: profile,
      );

      authenticationService.addUser(appUser);

      await authenticationService.afterSignIn(appUser);
    }
  }

  _handleSharingProviderChange() {
    if (!sharingIntentProvider.applicationLoadComplete ||
        sharingIntentProvider.deepLink == null) {
      return;
    }

    switch (sharingIntentProvider.deepLink) {
      case "notifications":
        {
          final navigationService = locator<NavigationService>();

          navigationService.push(
            MaterialPageRoute(builder: (_) => Notifications()),
          );
          break;
        }
      default:
        break;
    }
  }
}
