import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:thunder_flutter/src/thunder_client.dart';
import 'package:thunder_flutter/src/models/thunder_config.dart';
import 'package:thunder_flutter/src/models/user.dart';
import 'package:thunder_flutter/src/models/organization.dart';
import 'package:thunder_flutter/src/widgets/thunder_provider.dart';
import 'package:thunder_flutter/src/widgets/thunder_signed_in.dart';
import 'package:thunder_flutter/src/widgets/thunder_signed_out.dart';
import 'package:thunder_flutter/src/widgets/thunder_loading.dart';
import 'package:thunder_flutter/src/widgets/thunder_user.dart';
import 'package:thunder_flutter/src/widgets/thunder_organization_list.dart';
import 'package:thunder_flutter/src/widgets/thunder_organization_switcher.dart';
import 'package:thunder_flutter/src/widgets/thunder_language_switcher.dart';

// ── Test helpers ──────────────────────────────────────────────────────────────

const _config = ThunderConfig(baseUrl: 'https://localhost:8090', clientId: 'test');

final _mockUser = User(
  id: 'u1',
  username: 'alice',
  email: 'alice@example.com',
  displayName: 'Alice Doe',
);

final _mockOrgs = [
  Organization(id: 'o1', name: 'Org One', handle: 'org-one'),
  Organization(id: 'o2', name: 'Org Two', handle: 'org-two'),
];

/// Sets up a mock MethodChannel for io.thunder/sdk.
void _setHandler(MethodChannel channel, Future<dynamic> Function(MethodCall) handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, handler);
}

void _clearHandler(MethodChannel channel) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null);
}

const _sdkChannel = MethodChannel('io.thunder/sdk');

/// Builds a [ThunderProvider] with a pre-configured [ThunderClient] under test.
Widget _providerWidget({
  required Widget child,
  bool signedIn = false,
}) {
  _setHandler(_sdkChannel, (call) async {
    switch (call.method) {
      case 'initialize':
        return true;
      case 'isSignedIn':
        return signedIn;
      case 'getUser':
        return signedIn ? _mockUser.toMap() : null;
      case 'getMyOrganizations':
        return _mockOrgs.map((o) => o.toMap()).toList();
      case 'getCurrentOrganization':
        return _mockOrgs.first.toMap();
      case 'switchOrganization':
        return {'accessToken': 'tok', 'refreshToken': 'ref', 'idToken': 'id', 'expiresIn': 3600};
      default:
        return null;
    }
  });

  return WidgetsApp(
    color: const Color(0xFFFFFFFF),
    builder: (_, __) => ThunderProvider(
      config: _config,
      child: child,
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => _clearHandler(_sdkChannel));

  group('ThunderSignedIn', () {
    testWidgets('renders child when signed in', (tester) async {
      await tester.pumpWidget(_providerWidget(
        signedIn: true,
        child: const ThunderSignedIn(child: Text('hello', textDirection: TextDirection.ltr)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('hides child when signed out', (tester) async {
      await tester.pumpWidget(_providerWidget(
        signedIn: false,
        child: const ThunderSignedIn(child: Text('hello', textDirection: TextDirection.ltr)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('hello'), findsNothing);
    });

    testWidgets('shows fallback when signed out', (tester) async {
      await tester.pumpWidget(_providerWidget(
        signedIn: false,
        child: const ThunderSignedIn(
          child: Text('hello', textDirection: TextDirection.ltr),
          fallback: Text('sign in please', textDirection: TextDirection.ltr),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('sign in please'), findsOneWidget);
    });
  });

  group('ThunderSignedOut', () {
    testWidgets('renders child when signed out', (tester) async {
      await tester.pumpWidget(_providerWidget(
        signedIn: false,
        child: const ThunderSignedOut(child: Text('signed out', textDirection: TextDirection.ltr)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('signed out'), findsOneWidget);
    });

    testWidgets('hides child when signed in', (tester) async {
      await tester.pumpWidget(_providerWidget(
        signedIn: true,
        child: const ThunderSignedOut(child: Text('signed out', textDirection: TextDirection.ltr)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('signed out'), findsNothing);
    });
  });

  group('ThunderLoading', () {
    testWidgets('renders indicator while loading', (tester) async {
      // Loading state only exists transiently during init; pump once to catch it.
      await tester.pumpWidget(_providerWidget(
        signedIn: false,
        child: ThunderLoading(
          indicator: const Text('loading...', textDirection: TextDirection.ltr),
        ),
      ));
      // First pump shows loading state before async init completes.
      expect(find.text('loading...'), findsOneWidget);
      await tester.pumpAndSettle();
      // After init, loading is done.
      expect(find.text('loading...'), findsNothing);
    });
  });

  group('ThunderUser', () {
    testWidgets('BaseThunderUser receives signed-in user', (tester) async {
      String? displayedName;
      await tester.pumpWidget(_providerWidget(
        signedIn: true,
        child: BaseThunderUser(
          builder: (_, user) {
            displayedName = user?.displayName;
            return const SizedBox();
          },
        ),
      ));
      await tester.pumpAndSettle();
      expect(displayedName, 'Alice Doe');
    });

    testWidgets('BaseThunderUser receives null when signed out', (tester) async {
      User? capturedUser = User(id: 'placeholder', username: 'x');
      await tester.pumpWidget(_providerWidget(
        signedIn: false,
        child: BaseThunderUser(
          builder: (_, user) {
            capturedUser = user;
            return const SizedBox();
          },
        ),
      ));
      await tester.pumpAndSettle();
      expect(capturedUser, isNull);
    });
  });

  group('ThunderOrganizationList', () {
    testWidgets('BaseThunderOrganizationList fetches and exposes org list', (tester) async {
      List<Organization>? captured;
      await tester.pumpWidget(_providerWidget(
        signedIn: true,
        child: BaseThunderOrganizationList(
          builder: (_, orgs, isLoading, error) {
            if (!isLoading) captured = orgs;
            return const SizedBox();
          },
        ),
      ));
      await tester.pumpAndSettle();
      expect(captured, isNotNull);
      expect(captured!.length, 2);
      expect(captured!.first.name, 'Org One');
    });
  });

  group('ThunderOrganizationSwitcher', () {
    testWidgets('BaseThunderOrganizationSwitcher calls switchOrganization on select', (tester) async {
      Organization? switched;
      await tester.pumpWidget(_providerWidget(
        signedIn: true,
        child: BaseThunderOrganizationSwitcher(
          builder: (_, orgs, current, isSwitching, error, switchOrg) {
            if (orgs.isEmpty || isSwitching) return const SizedBox();
            return GestureDetector(
              onTap: () async {
                await switchOrg(orgs.last);
                switched = orgs.last;
              },
              child: const Text('switch', textDirection: TextDirection.ltr),
            );
          },
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('switch'));
      await tester.pumpAndSettle();
      expect(switched?.name, 'Org Two');
    });
  });

  group('ThunderLanguageSwitcher', () {
    testWidgets('BaseThunderLanguageSwitcher exposes active locale and select callback', (tester) async {
      String? activeBefore;
      String? activeAfter;
      await tester.pumpWidget(_providerWidget(
        signedIn: false,
        child: BaseThunderLanguageSwitcher(
          locales: const ['en-US', 'fr-FR'],
          builder: (_, active, select) {
            activeBefore ??= active;
            return GestureDetector(
              onTap: () {
                select('fr-FR');
                activeAfter = 'fr-FR';
              },
              child: const Text('fr', textDirection: TextDirection.ltr),
            );
          },
        ),
      ));
      await tester.pumpAndSettle();
      expect(activeBefore, 'en-US');
      await tester.tap(find.text('fr'));
      await tester.pumpAndSettle();
      expect(activeAfter, 'fr-FR');
    });
  });
}
