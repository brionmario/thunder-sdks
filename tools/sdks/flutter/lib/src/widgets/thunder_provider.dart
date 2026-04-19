import 'dart:async';

import 'package:flutter/widgets.dart';
import '../thunder_client.dart';
import '../models/thunder_config.dart';
import '../models/preferences.dart';
import '../models/user.dart';
import '../i18n/thunder_i18n.dart';

/// Provides a [ThunderClient] and reactive authentication state to the widget tree.
///
/// Wrap your root widget with [ThunderProvider]:
/// ```dart
/// ThunderProvider(
///   config: ThunderConfig(baseUrl: '...', clientId: '...'),
///   child: MyApp(),
/// )
/// ```
class ThunderProvider extends StatefulWidget {
  final ThunderConfig config;
  final Widget child;
  final ThunderClient? client;

  const ThunderProvider({
    super.key,
    required this.config,
    required this.child,
    this.client,
  });

  static ThunderState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ThunderScope>();
    assert(scope != null, 'No ThunderProvider found in widget tree');
    return scope!.state;
  }

  @override
  State<ThunderProvider> createState() => ThunderState();
}

class ThunderState extends State<ThunderProvider> {
  late final ThunderClient client;
  late final ThunderI18n i18n;
  bool _initialized = false;
  bool _isLoading = false;
  User? _user;
  String? _error;

  bool get initialized => _initialized;
  bool get isLoading => _isLoading;
  User? get user => _user;
  bool get isSignedIn => _user != null;
  String? get error => _error;
  ThunderPreferences? get preferences => widget.config.preferences;

  @override
  void initState() {
    super.initState();
    client = widget.client ?? ThunderClient();
    i18n = ThunderI18n(widget.config.preferences?.i18n);
    _init();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      await client.initialize(widget.config).timeout(const Duration(seconds: 15));
      final signedIn = await client.isSignedIn().timeout(const Duration(seconds: 10));
      if (signedIn) {
        _user = await client.getUser().timeout(const Duration(seconds: 10));
      }
      _initialized = true;
      _error = null;
    } on TimeoutException {
      _error = 'Initialization timed out. Verify THUNDER_BASE_URL and that the Thunder server is reachable.';
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> refresh() async {
    if (!_initialized) return;
    setState(() => _isLoading = true);
    try {
      final signedIn = await client.isSignedIn();
      _user = signedIn ? await client.getUser() : null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Switches the active locale for UI component labels.
  void setLocale(String locale) {
    i18n.setLocale(locale);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => _ThunderScope(
        state: this,
        isSignedIn: isSignedIn,
        isLoading: isLoading,
        error: error,
        activeLocale: i18n.activeLocale,
        child: widget.child,
      );
}

class _ThunderScope extends InheritedWidget {
  final ThunderState state;
  final bool isSignedIn;
  final bool isLoading;
  final String? error;
  final String activeLocale;

  const _ThunderScope({
    required this.state,
    required this.isSignedIn,
    required this.isLoading,
    required this.error,
    required this.activeLocale,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ThunderScope oldWidget) =>
      isSignedIn != oldWidget.isSignedIn ||
      isLoading != oldWidget.isLoading ||
      error != oldWidget.error ||
      activeLocale != oldWidget.activeLocale;
}
