import 'package:flutter/material.dart';
import 'package:thunderid_flutter/thunderid_flutter.dart';
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
    final thunder = ThunderIDProvider.of(context);

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

    return thunder.isSignedIn ? const HomeScreen() : const AuthScreen();
  }
}
