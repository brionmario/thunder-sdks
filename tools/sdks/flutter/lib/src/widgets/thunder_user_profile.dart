import 'package:flutter/widgets.dart';
import 'thunder_provider.dart';
import '../models/user_profile.dart';

/// Editable profile management UI (spec §8.4 Presentation).
/// Calls [getUserProfile()] on mount and [updateUserProfile()] on save.
class ThunderUserProfile extends StatelessWidget {
  final VoidCallback? onSaved;
  final VoidCallback? onError;

  const ThunderUserProfile({super.key, this.onSaved, this.onError});

  @override
  Widget build(BuildContext context) {
    final state = ThunderProvider.of(context);
    return BaseThunderUserProfile(
      onSaved: onSaved,
      onError: onError,
      builder: (ctx, profile, controllers, isLoading, error, save) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(state.i18n.resolve('userProfile.title')),
          const SizedBox(height: 16),
          if (isLoading && profile == null)
            Text(state.i18n.resolve('userProfile.loading'))
          else if (error != null)
            Text(error)
          else ...[
            for (final entry in controllers.entries) ...[
              Semantics(
                label: entry.key,
                child: SizedBox(
                  height: 44,
                  child: EditableText(
                    controller: entry.value,
                    focusNode: FocusNode(),
                    style: const TextStyle(fontSize: 16),
                    cursorColor: const Color(0xFF000000),
                    backgroundCursorColor: const Color(0xFF000000),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            GestureDetector(
              onTap: isLoading ? null : save,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                child: Text(state.i18n.resolve('userProfile.save')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Unstyled base variant (spec §8.3).
class BaseThunderUserProfile extends StatefulWidget {
  final VoidCallback? onSaved;
  final VoidCallback? onError;
  final Widget Function(
    BuildContext context,
    UserProfile? profile,
    Map<String, TextEditingController> controllers,
    bool isLoading,
    String? error,
    VoidCallback save,
  ) builder;

  const BaseThunderUserProfile({
    super.key,
    required this.builder,
    this.onSaved,
    this.onError,
  });

  @override
  State<BaseThunderUserProfile> createState() => _BaseThunderUserProfileState();
}

class _BaseThunderUserProfileState extends State<BaseThunderUserProfile> {
  UserProfile? _profile;
  final _controllers = <String, TextEditingController>{};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final state = ThunderProvider.of(context);
      final profile = await state.client.getUserProfile();
      final editableClaims = <String>['displayName', 'phoneNumbers'];
      for (final key in editableClaims) {
        final value = profile.claims[key]?.toString() ?? '';
        _controllers.putIfAbsent(key, () => TextEditingController(text: value));
      }
      if (mounted) setState(() => _profile = profile);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final state = ThunderProvider.of(context);
      await state.client.updateUserProfile(
        _controllers.map((k, v) => MapEntry(k, v.text)),
      );
      widget.onSaved?.call();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      widget.onError?.call();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _profile, _controllers, _isLoading, _error, _save);
}
