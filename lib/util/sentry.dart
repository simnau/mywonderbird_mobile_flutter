import 'package:layout/locator.dart';
import 'package:sentry/sentry.dart';

bool get isInDebugMode {
  // Assume you're in production mode.
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  return inDebugMode;
}

Future<void> reportError(dynamic error, dynamic stackTrace) async {
  // Print the exception to the console.
  print('Caught error: $error');
  if (isInDebugMode) {
    // Print the full stacktrace in debug mode.
    print(stackTrace);
  } else {
    final sentryClient = locator<SentryClient>();
    // Send the Exception and Stacktrace to Sentry in Production mode.
    if (sentryClient != null) {
      sentryClient.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }
}
