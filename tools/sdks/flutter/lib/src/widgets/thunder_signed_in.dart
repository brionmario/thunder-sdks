import 'package:flutter/widgets.dart';
import 'thunder_provider.dart';

/// Renders [child] only when the user is authenticated. Renders [fallback] (or
/// nothing) otherwise (spec §8.4 Control/Guard).
class ThunderSignedIn extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ThunderSignedIn({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    final state = ThunderProvider.of(context);
    if (state.isSignedIn) return child;
    return fallback ?? const SizedBox.shrink();
  }
}
