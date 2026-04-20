import 'package:flutter/material.dart';
import 'package:thunder_flutter/thunder_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ThunderUserProfile(
            onSaved: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile saved')),
            ),
          ),
        ),
      ),
    );
  }
}
