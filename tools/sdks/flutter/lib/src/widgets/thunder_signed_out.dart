import 'package:flutter/widgets.dart';
import 'thunder_provider.dart';

/// Renders [child] only when no user is authenticated (spec §8.4 Control/Guard).
class ThunderSignedOut extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ThunderSignedOut({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    final state = ThunderProvider.of(context);
    if (!state.isSignedIn) return child;
    return fallback ?? const SizedBox.shrink();
  }
}
