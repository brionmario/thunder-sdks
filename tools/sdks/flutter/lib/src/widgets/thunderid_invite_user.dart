import 'package:flutter/widgets.dart';
import 'thunderid_provider.dart';

/// Admin UI to invite a new user by email (spec §8.4 Presentation).
/// Requires admin privileges on the ThunderID server.
class ThunderIDInviteUser extends StatelessWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const ThunderIDInviteUser({super.key, this.onSuccess, this.onError});

  @override
  Widget build(BuildContext context) {
    final state = ThunderIDProvider.of(context);
    return BaseThunderIDInviteUser(
      onSuccess: onSuccess,
      onError: onError,
      builder: (ctx, ctrl, isLoading, error) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(state.i18n.resolve('inviteUser.title')),
          const SizedBox(height: 16),
          Semantics(
            label: state.i18n.resolve('inviteUser.email'),
            child: SizedBox(
              height: 44,
              child: EditableText(
                controller: ctrl,
                focusNode: FocusNode(),
                style: const TextStyle(fontSize: 16),
                cursorColor: const Color(0xFF000000),
                backgroundCursorColor: const Color(0xFF000000),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),
          if (error != null) Text(error),
          GestureDetector(
            onTap: isLoading ? null : () => ctx.findAncestorStateOfType<_BaseThunderIDInviteUserState>()!._submit(),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              child: Text(state.i18n.resolve('inviteUser.submit')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Unstyled base variant (spec §8.3).
class BaseThunderIDInviteUser extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final Widget Function(
    BuildContext context,
    TextEditingController emailController,
    bool isLoading,
    String? error,
  ) builder;

  const BaseThunderIDInviteUser({
    super.key,
    required this.builder,
    this.onSuccess,
    this.onError,
  });

  @override
  State<BaseThunderIDInviteUser> createState() => _BaseThunderIDInviteUserState();
}

class _BaseThunderIDInviteUserState extends State<BaseThunderIDInviteUser> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final state = ThunderIDProvider.of(context);
      await state.client.updateUserProfile({'email': _emailCtrl.text});
      widget.onSuccess?.call();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      widget.onError?.call();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _emailCtrl, _isLoading, _error);
}
