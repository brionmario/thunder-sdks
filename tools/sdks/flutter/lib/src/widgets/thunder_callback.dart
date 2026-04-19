import 'package:flutter/widgets.dart';
import 'thunder_provider.dart';
import '../models/user.dart';

/// Handles the OAuth2 redirect callback URL (spec §8.4 Auth Flow).
///
/// Use this widget at the route your app receives the deep-link callback on
/// after a redirect-based sign-in. Pass the full callback URL including the
/// `code` query parameter.
///
/// ```dart
/// ThunderCallback(
///   url: callbackUrl,
///   onSuccess: (user) => Navigator.pushReplacementNamed(context, '/home'),
///   onError: (e) => Navigator.pushReplacementNamed(context, '/signin'),
/// )
/// ```
class ThunderCallback extends StatelessWidget {
  final String url;
  final void Function(User user)? onSuccess;
  final void Function(Object error)? onError;
  final Widget? loadingIndicator;

  const ThunderCallback({
    super.key,
    required this.url,
    this.onSuccess,
    this.onError,
    this.loadingIndicator,
  });

  @override
  Widget build(BuildContext context) {
    final state = ThunderProvider.of(context);
    return BaseThunderCallback(
      url: url,
      onSuccess: onSuccess,
      onError: onError,
      builder: (ctx, isLoading, error) {
        if (error != null) {
          return Text(state.i18n.resolve('callback.error'));
        }
        return loadingIndicator ??
            Center(child: Text(state.i18n.resolve('callback.loading')));
      },
    );
  }
}

/// Unstyled base variant (spec §8.2).
class BaseThunderCallback extends StatefulWidget {
  final String url;
  final void Function(User user)? onSuccess;
  final void Function(Object error)? onError;
  final Widget Function(BuildContext context, bool isLoading, Object? error) builder;

  const BaseThunderCallback({
    super.key,
    required this.url,
    required this.builder,
    this.onSuccess,
    this.onError,
  });

  @override
  State<BaseThunderCallback> createState() => _BaseThunderCallbackState();
}

class _BaseThunderCallbackState extends State<BaseThunderCallback> {
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _exchange();
  }

  Future<void> _exchange() async {
    try {
      final state = ThunderProvider.of(context);
      final user = await state.client.handleRedirectCallback(widget.url);
      await state.refresh();
      widget.onSuccess?.call(user);
    } catch (e) {
      if (mounted) setState(() => _error = e);
      widget.onError?.call(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _isLoading, _error);
}
