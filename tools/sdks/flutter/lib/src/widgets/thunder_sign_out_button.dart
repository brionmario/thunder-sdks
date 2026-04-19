import 'package:flutter/widgets.dart';
import 'thunder_provider.dart';
import '../models/sign_out_options.dart';

/// Triggers sign-out on tap. Accessible per WCAG 2.1 AA (spec §8.1).
class ThunderSignOutButton extends StatelessWidget {
  final SignOutOptions? options;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const ThunderSignOutButton({super.key, this.options, this.onSuccess, this.onError});

  @override
  Widget build(BuildContext context) {
    final state = ThunderProvider.of(context);
    final label = state.i18n.resolve('signOut.button');
    return BaseThunderSignOutButton(
      options: options,
      onSuccess: onSuccess,
      onError: onError,
      builder: (ctx, isLoading) => Semantics(
        label: label,
        button: true,
        child: GestureDetector(
          onTap: isLoading ? null : () => _signOut(ctx),
          child: Container(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final state = ThunderProvider.of(context);
    try {
      await state.client.signOut(options: options);
      await state.refresh();
      onSuccess?.call();
    } catch (_) {
      onError?.call();
    }
  }
}

/// Unstyled base variant for full style customization (spec §8.2).
class BaseThunderSignOutButton extends StatefulWidget {
  final SignOutOptions? options;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final Widget Function(BuildContext context, bool isLoading) builder;

  const BaseThunderSignOutButton({
    super.key,
    required this.builder,
    this.options,
    this.onSuccess,
    this.onError,
  });

  @override
  State<BaseThunderSignOutButton> createState() => _BaseThunderSignOutButtonState();
}

class _BaseThunderSignOutButtonState extends State<BaseThunderSignOutButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _signOut,
      child: widget.builder(context, _isLoading),
    );
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      final state = ThunderProvider.of(context);
      await state.client.signOut(options: widget.options);
      await state.refresh();
      widget.onSuccess?.call();
    } catch (_) {
      widget.onError?.call();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
