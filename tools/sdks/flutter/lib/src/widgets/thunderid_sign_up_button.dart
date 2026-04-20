import 'package:flutter/widgets.dart';
import 'thunderid_provider.dart';
import '../models/sign_up_options.dart';
import '../models/flow_models.dart';

/// Initiates the sign-up flow on tap (spec §8.4 Actions).
class ThunderIDSignUpButton extends StatelessWidget {
  final SignUpOptions? options;
  final void Function(EmbeddedFlowResponse)? onFlowStarted;
  final VoidCallback? onError;

  const ThunderIDSignUpButton({super.key, this.options, this.onFlowStarted, this.onError});

  @override
  Widget build(BuildContext context) {
    final state = ThunderIDProvider.of(context);
    final label = state.i18n.resolve('signUp.button');
    return BaseThunderIDSignUpButton(
      options: options,
      onFlowStarted: onFlowStarted,
      onError: onError,
      builder: (ctx, isLoading) => Semantics(
        label: label,
        button: true,
        child: GestureDetector(
          onTap: isLoading ? null : () => _startSignUp(ctx),
          child: Container(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Future<void> _startSignUp(BuildContext context) async {
    final state = ThunderIDProvider.of(context);
    try {
      final response = await state.client.signUp();
      onFlowStarted?.call(response);
    } catch (_) {
      onError?.call();
    }
  }
}

/// Unstyled base variant (spec §8.2).
class BaseThunderIDSignUpButton extends StatefulWidget {
  final SignUpOptions? options;
  final void Function(EmbeddedFlowResponse)? onFlowStarted;
  final VoidCallback? onError;
  final Widget Function(BuildContext context, bool isLoading) builder;

  const BaseThunderIDSignUpButton({
    super.key,
    required this.builder,
    this.options,
    this.onFlowStarted,
    this.onError,
  });

  @override
  State<BaseThunderIDSignUpButton> createState() => _BaseThunderIDSignUpButtonState();
}

class _BaseThunderIDSignUpButtonState extends State<BaseThunderIDSignUpButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) =>
      GestureDetector(onTap: _isLoading ? null : _start, child: widget.builder(context, _isLoading));

  Future<void> _start() async {
    setState(() => _isLoading = true);
    try {
      final state = ThunderIDProvider.of(context);
      final response = await state.client.signUp();
      widget.onFlowStarted?.call(response);
    } catch (_) {
      widget.onError?.call();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
