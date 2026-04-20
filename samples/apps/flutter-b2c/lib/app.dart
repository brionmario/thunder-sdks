import 'package:flutter/material.dart';
import 'package:thunder_flutter/thunder_flutter.dart';
import 'assertion_session.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

class FlutterB2CApp extends StatelessWidget {
  const FlutterB2CApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACME Booking',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFFF5A5F),
        useMaterial3: true,
      ),
      home: const _RootScreen(),
    );
  }
}

class _RootScreen extends StatelessWidget {
  const _RootScreen();

  @override
  Widget build(BuildContext context) {
    final thunder = ThunderProvider.of(context);

    if (thunder.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Starting ACME Booking\u2026'),
            ],
          ),
        ),
      );
    }

    if (thunder.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Configuration error: ${thunder.error}\n\nCheck your .env values.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return ValueListenableBuilder<String?>(
      valueListenable: AssertionSession.assertion,
      builder: (context, assertion, _) {
        final showHome = thunder.isSignedIn || (assertion?.isNotEmpty ?? false);
        return showHome ? const HomeScreen() : const AuthScreen();
      },
    );
  }
}
