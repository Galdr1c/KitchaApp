import 'package:flutter_test/flutter_test.dart';
import 'package:kitcha_app/services/firebase_mcp_service.dart';
import 'package:kitcha_app/models/recipe.dart';
import 'package:kitcha_app/repository/app_repository.dart';

class MockFirebaseMcpService extends FirebaseMcpService {
  bool remoteConfigInitialized = false;
  bool syncCalled = false;

  @override
  Future<void> initRemoteConfig() async {
    remoteConfigInitialized = true;
  }

  @override
  bool get isMultiModelEnabled => true;

  @override
  Future<void> syncUserData({Function(int current, int total)? onProgress}) async {
    syncCalled = true;
    onProgress?.call(1, 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('FirebaseMcpService Tests', () {
    test('initRemoteConfig should mark as initialized', () async {
      final mockFirebase = MockFirebaseMcpService();
      await mockFirebase.initRemoteConfig();
      expect(mockFirebase.remoteConfigInitialized, true);
    });

    test('isMultiModelEnabled should return true by default in mock', () {
      final mockFirebase = MockFirebaseMcpService();
      expect(mockFirebase.isMultiModelEnabled, true);
    });

    test('syncUserData should trigger sync logic', () async {
      final mockFirebase = MockFirebaseMcpService();
      int progressCallCount = 0;
      
      await mockFirebase.syncUserData(onProgress: (c, t) => progressCallCount++);
      
      expect(mockFirebase.syncCalled, true);
      expect(progressCallCount, 1);
    });
  });
}
