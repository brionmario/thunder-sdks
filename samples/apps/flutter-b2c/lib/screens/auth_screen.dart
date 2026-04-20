import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thunder_flutter/thunder_flutter.dart';

enum _AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthMode _mode = _AuthMode.signIn;

  @override
  Widget build(BuildContext context) {
    final applicationId = dotenv.env['THUNDER_APP_ID'] ?? '';
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: cs.primary,
                      child: Icon(Icons.home_filled, size: 36, color: cs.onPrimary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ACME Booking',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find your perfect stay',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SegmentedButton<_AuthMode>(
                segments: const [
                  ButtonSegment(value: _AuthMode.signIn, label: Text('Sign In')),
                  ButtonSegment(value: _AuthMode.signUp, label: Text('Create Account')),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _mode == _AuthMode.signIn
                      ? ThunderSignIn(applicationId: applicationId)
                      : ThunderSignUp(applicationId: applicationId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
