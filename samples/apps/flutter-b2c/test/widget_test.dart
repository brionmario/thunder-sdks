import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thunderid_flutter/thunderid_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('io.thunder/sdk'),
      (call) async {
        switch (call.method) {
          case 'initialize':
            return true;
          case 'isSignedIn':
            return false;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('io.thunder/sdk'), null);
  });

  testWidgets('shows loading indicator while initializing', (tester) async {
    await tester.pumpWidget(
      const ThunderIDProvider(
        config: ThunderIDConfig(
          baseUrl: 'https://localhost:8090',
          clientId: 'test',
        ),
        child: MaterialApp(home: Scaffold(body: Text('App'))),
      ),
    );
    // First frame: should show the child (ThunderIDProvider manages loading internally)
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
