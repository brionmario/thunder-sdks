import 'package:flutter/material.dart';
import 'package:thunder_flutter/thunder_flutter.dart';
import '../assertion_session.dart';
import 'profile_screen.dart';

/// Authenticated dashboard — showcasing [ThunderUser], [ThunderUserDropdown],
/// and [BaseThunderSignOutButton].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACME'),
        centerTitle: false,
        actions: [
          // ThunderUserDropdown: avatar chip with inline profile / sign-out menu.
          ThunderUserDropdown(
            onProfileTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Welcome card ───────────────────────────────────────────────
            // ThunderUser renders the signed-in user's avatar and display name.
            Card(
              elevation: 0,
              color: cs.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(height: 8),
                    ThunderUser(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Quick actions ──────────────────────────────────────────────
            Text('Quick Actions',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.person_outline,
              label: 'My Profile',
              subtitle: 'View and edit your details',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              ),
            ),
            const SizedBox(height: 20),

            // ── Sign-out ───────────────────────────────────────────────────
            // BaseThunderSignOutButton allows a fully custom Material button
            // while the SDK handles the sign-out + state-refresh lifecycle.
            BaseThunderSignOutButton(
              onSuccess: AssertionSession.clear,
              onError: AssertionSession.clear,
              builder: (ctx, isLoading) => OutlinedButton.icon(
                onPressed: null,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
