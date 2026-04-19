import 'package:flutter/material.dart';
import 'package:thunder_flutter/thunder_flutter.dart';

/// Profile editing — showcasing [ThunderUserProfile].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ThunderUserProfile(
                onSaved: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile saved')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
