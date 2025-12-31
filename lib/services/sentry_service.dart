import 'package:sentry_flutter/sentry_flutter.dart';
import '../config/env.dart';

class SentryService {
  static final SentryService _instance = SentryService._internal();
  factory SentryService() => _instance;
  SentryService._internal();

  /// Log a non-fatal exception to Sentry
  static Future<void> captureException(dynamic exception, {dynamic stackTrace, String? reason}) async {
    if (!Env.isProduction) {
      print('[Sentry Mocked] Exception: $exception');
      return;
    }
    
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (reason != null) {
          scope.setTag('reason', reason);
        }
      },
    );
  }

  /// Log a message for breadcrumbs or info
  static void logMessage(String message, {SentryLevel level = SentryLevel.info}) {
    if (!Env.isProduction) {
       print('[Sentry Mocked] $message');
       return;
    }
    Sentry.addBreadcrumb(Breadcrumb(message: message, level: level));
  }

  /// Start a performance transaction
  static ISentrySpan startTransaction(String name, String operation) {
    return Sentry.startTransaction(name, operation);
  }
}
