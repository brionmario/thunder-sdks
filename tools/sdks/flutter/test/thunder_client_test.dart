import 'package:flutter_test/flutter_test.dart';
import 'package:thunder_flutter/src/thunder_client.dart';
import 'package:thunder_flutter/src/models/thunder_config.dart';
import 'package:thunder_flutter/src/models/iam_error.dart';
import 'package:thunder_flutter/src/channel/thunder_channel.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThunderClient client;
  final List<MethodCall> log = [];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('io.thunder/sdk'),
      (call) async {
        log.add(call);
        switch (call.method) {
          case 'initialize':
            return true;
          case 'isSignedIn':
            return false;
          case 'signOut':
            return '/';
          case 'getAccessToken':
            return 'mock-access-token';
          default:
            return null;
        }
      },
    );
    client = ThunderClient();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('io.thunder/sdk'), null);
  });

  group('initialization', () {
    test('initialize calls native channel with config', () async {
      const config = ThunderConfig(
        baseUrl: 'https://localhost:8090',
        clientId: 'test-client',
      );
      final result = await client.initialize(config);
      expect(result, true);
      expect(log.any((c) => c.method == 'initialize'), true);
    });

    test('initialize throws ALREADY_INITIALIZED when called twice', () async {
      const config = ThunderConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
      await client.initialize(config);
      expect(
        () => client.initialize(config),
        throwsA(isA<IAMException>().having((e) => e.code, 'code', IAMErrorCode.alreadyInitialized)),
      );
    });

    test('operations before init throw SDK_NOT_INITIALIZED', () {
      expect(
        () => client.isSignedIn(),
        throwsA(isA<IAMException>().having((e) => e.code, 'code', IAMErrorCode.sdkNotInitialized)),
      );
    });
  });

  group('isLoading', () {
    test('isLoading returns false when not active', () async {
      const config = ThunderConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
      await client.initialize(config);
      expect(client.isLoading(), false);
    });
  });

  group('IAMErrorCode', () {
    test('fromString parses known codes', () {
      expect(IAMErrorCode.fromString('AUTHENTICATION_FAILED'), IAMErrorCode.authenticationFailed);
      expect(IAMErrorCode.fromString('SESSION_EXPIRED'), IAMErrorCode.sessionExpired);
      expect(IAMErrorCode.fromString('SDK_NOT_INITIALIZED'), IAMErrorCode.sdkNotInitialized);
    });

    test('fromString returns unknownError for unknown code', () {
      expect(IAMErrorCode.fromString('NOT_REAL'), IAMErrorCode.unknownError);
    });

    test('IAMException toString includes code', () {
      final e = IAMException(IAMErrorCode.networkError, 'connection refused');
      expect(e.toString(), contains('NETWORK_ERROR'));
    });
  });

  group('ThunderConfig', () {
    test('toMap includes required fields', () {
      const config = ThunderConfig(
        baseUrl: 'https://localhost:8090',
        clientId: 'client-123',
        scopes: ['openid', 'profile'],
      );
      final map = config.toMap();
      expect(map['baseUrl'], 'https://localhost:8090');
      expect(map['clientId'], 'client-123');
      expect(map['scopes'], ['openid', 'profile']);
    });

    test('toMap omits null optional fields', () {
      const config = ThunderConfig(baseUrl: 'https://localhost:8090');
      final map = config.toMap();
      expect(map.containsKey('clientId'), false);
      expect(map.containsKey('afterSignInUrl'), false);
    });
  });

  group('sign-out', () {
    test('signOut delegates to native and returns afterSignOutUrl', () async {
      const config = ThunderConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
      await client.initialize(config);
      final result = await client.signOut();
      expect(result, '/');
    });
  });

  group('getAccessToken', () {
    test('returns token from native layer', () async {
      const config = ThunderConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
      await client.initialize(config);
      final token = await client.getAccessToken();
      expect(token, 'mock-access-token');
    });
  });
}
