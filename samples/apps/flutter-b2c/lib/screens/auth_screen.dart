import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thunder_flutter/thunder_flutter.dart';
import '../assertion_session.dart';

enum _AuthMode { signIn, signUp }

/// Unauthenticated entry point — ACME branded.
/// Uses [BaseThunderSignIn] / [BaseThunderSignUp] and renders the form
/// directly from the server's [meta.components] component tree.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthMode _mode = _AuthMode.signIn;
  FlowTemplateResolver? _resolver;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchMeta);
  }

  Future<void> _fetchMeta() async {
    final applicationId = dotenv.env['THUNDER_APP_ID'] ?? '';
    if (applicationId.isEmpty) return;
    try {
      final thunder = ThunderProvider.of(context);
      final meta = await thunder.client.getFlowMeta(applicationId);
      if (mounted) setState(() => _resolver = FlowTemplateResolver(meta));
    } catch (_) {
      // non-fatal — template strings fall back to their fallback values
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationId = dotenv.env['THUNDER_APP_ID'] ?? '';
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── ACME Logo ──────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: cs.primary,
                      child: Icon(
                        Icons.home_filled,
                        size: 36,
                        color: cs.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ACME Booking',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find your perfect stay',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Mode toggle ────────────────────────────────────────────────
              SegmentedButton<_AuthMode>(
                segments: const [
                  ButtonSegment(value: _AuthMode.signIn, label: Text('Sign In')),
                  ButtonSegment(
                      value: _AuthMode.signUp, label: Text('Create Account')),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: 28),

              // ── SDK Component ──────────────────────────────────────────────
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _mode == _AuthMode.signIn
                      ? _MaterialSignIn(applicationId: applicationId, resolver: _resolver)
                      : _MaterialSignUp(applicationId: applicationId, resolver: _resolver),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign In
// ─────────────────────────────────────────────────────────────────────────────

class _MaterialSignIn extends StatefulWidget {
  final String applicationId;
  final FlowTemplateResolver? resolver;
  const _MaterialSignIn({required this.applicationId, this.resolver});

  @override
  State<_MaterialSignIn> createState() => _MaterialSignInState();
}

class _MaterialSignInState extends State<_MaterialSignIn> {
  final _controllers = <String, TextEditingController>{};
  String? _handledAssertion;
  bool _isCompleting = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thunder = ThunderProvider.of(context);
    return BaseThunderSignIn(
      applicationId: widget.applicationId,
      builder: (ctx, state) {
        _maybeCompleteSignIn(thunder, state.currentStep);
        return _FlowForm(
          state: _FlowFormState(
            currentStep: state.currentStep,
            isLoading: state.isLoading,
            error: state.error,
            submit: state.submit,
          ),
          controllers: _controllers,
          resolver: widget.resolver,
        );
      },
    );
  }

  void _maybeCompleteSignIn(ThunderState thunder, EmbeddedFlowResponse? step) {
    if (_isCompleting || step == null) return;

    final assertion = step.assertion;
    final isComplete = step.flowStatus == FlowStatus.complete ||
        (assertion?.isNotEmpty ?? false);
    if (!isComplete || assertion == null || assertion.isEmpty) return;
    if (_handledAssertion == assertion) return;

    _isCompleting = true;
    Future<void>(() async {
      if (kDebugMode) {
        debugPrint('[B2C] assertion JWT: $assertion');
        debugPrint('[B2C] assertion payload: ${_decodeJwtPayload(assertion)}');
      }
      AssertionSession.setAssertion(assertion);
      try {
        await thunder.refresh();
      } catch (_) {
        // BaseThunderSignIn will surface errors through its state.
      } finally {
        if (mounted) {
          setState(() {
            _handledAssertion = assertion;
            _isCompleting = false;
          });
        }
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign Up
// ─────────────────────────────────────────────────────────────────────────────

class _MaterialSignUp extends StatefulWidget {
  final String applicationId;
  final FlowTemplateResolver? resolver;
  const _MaterialSignUp({required this.applicationId, this.resolver});

  @override
  State<_MaterialSignUp> createState() => _MaterialSignUpState();
}

class _MaterialSignUpState extends State<_MaterialSignUp> {
  final _controllers = <String, TextEditingController>{};
  String? _handledAssertion;
  bool _isCompleting = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thunder = ThunderProvider.of(context);
    return BaseThunderSignUp(
      applicationId: widget.applicationId,
      builder: (ctx, state) {
        _maybeCompleteSignUp(thunder, state.currentStep);
        return _FlowForm(
          state: _FlowFormState(
            currentStep: state.currentStep,
            isLoading: state.isLoading,
            error: state.error,
            submit: state.submit,
          ),
          controllers: _controllers,
          resolver: widget.resolver,
        );
      },
    );
  }

  void _maybeCompleteSignUp(ThunderState thunder, EmbeddedFlowResponse? step) {
    if (_isCompleting || step == null) return;

    final assertion = step.assertion;
    final isComplete = step.flowStatus == FlowStatus.complete ||
        (assertion?.isNotEmpty ?? false);
    if (!isComplete || assertion == null || assertion.isEmpty) return;
    if (_handledAssertion == assertion) return;

    _isCompleting = true;
    Future<void>(() async {
      AssertionSession.setAssertion(assertion);
      try {
        await thunder.refresh();
      } catch (_) {
        // BaseThunderSignUp will surface errors through its state.
      } finally {
        if (mounted) {
          setState(() {
            _handledAssertion = assertion;
            _isCompleting = false;
          });
        }
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic meta.components renderer (shared between sign-in and sign-up)
// ─────────────────────────────────────────────────────────────────────────────

class _FlowFormState {
  final EmbeddedFlowResponse? currentStep;
  final bool isLoading;
  final String? error;
  final Future<void> Function(String actionId, Map<String, String> inputs) submit;

  const _FlowFormState({
    required this.currentStep,
    required this.isLoading,
    required this.error,
    required this.submit,
  });
}

class _FlowForm extends StatelessWidget {
  final _FlowFormState state;
  final Map<String, TextEditingController> controllers;
  final FlowTemplateResolver? resolver;

  const _FlowForm({required this.state, required this.controllers, this.resolver});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.currentStep == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final step = state.currentStep;
    final completeWithAssertion = step != null &&
        (step.flowStatus == FlowStatus.complete ||
            (step.assertion?.isNotEmpty ?? false));
    if (completeWithAssertion) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = state.currentStep?.data;
    final rawMeta = data?['meta'];
    final components =
        rawMeta is Map ? _readList(rawMeta['components']) : const <Map<String, dynamic>>[];
    final inputs = _readList(data?['inputs']);
    final actions = _readList(data?['actions']);
    final componentFieldRefs = _componentFieldRefs(components);
    final hasActionComponent = _hasActionComponent(components);
    final missingInputs = inputs.where((input) {
      final ref = _inputRef(input);
      return ref.isNotEmpty && !componentFieldRefs.contains(ref);
    }).toList(growable: false);

    if (kDebugMode) {
      debugPrint('[B2C] render components=${components.length} inputs=${inputs.length} actions=${actions.length} hasActionComponent=$hasActionComponent missingInputs=${missingInputs.map(_inputRef).toList()}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (components.isNotEmpty)
          ...components.map((c) => _renderComponent(context, c, actions))
        else
          // fallback: no meta — render from inputs/actions directly
          ..._fallback(context, data, actions),
        if (components.isNotEmpty)
          ...missingInputs.map((input) => _renderField(
                context,
                {
                  'ref': _inputRef(input),
                  'identifier': _inputRef(input),
                  'name': _inputRef(input),
                  'label': _capitalize(_inputRef(input)),
                  'type': input['type'],
                },
                _str(input['type']),
              )),
        if (components.isNotEmpty && !hasActionComponent && actions.isNotEmpty)
          ...actions.map(
            (action) => _renderAction(
              context,
              {
                'label': _str(action['label'], fallback: 'Submit'),
                'id': _str(action['id']),
                'ref': _str(action['ref']),
              },
              actions,
            ),
          ),
        if (state.error != null) ...[
          const SizedBox(height: 12),
          Text(
            state.error!,
            style: TextStyle(
                color: Theme.of(context).colorScheme.error, fontSize: 13),
          ),
        ],
      ],
    );
  }

  // ── Component renderer ────────────────────────────────────────────────────

  String _effectiveCategory(Map<String, dynamic> comp) {
    final category = _str(comp['category']);
    if (category.isNotEmpty) return category;
    switch (_str(comp['type'])) {
      case 'TEXT':
      case 'IMAGE':
      case 'RICH_TEXT':
        return 'DISPLAY';
      case 'BLOCK':
        return 'BLOCK';
      case 'TEXT_INPUT':
      case 'PASSWORD_INPUT':
      case 'EMAIL_INPUT':
      case 'NUMBER_INPUT':
        return 'FIELD';
      case 'ACTION':
        return 'ACTION';
      default:
        return '';
    }
  }

  Widget _renderComponent(
    BuildContext context,
    Map<String, dynamic> comp,
    List<Map<String, dynamic>> actions,
  ) {
    final category = _effectiveCategory(comp);
    final type = _str(comp['type']);

    switch (category) {
      case 'DISPLAY':
        return _renderDisplay(context, comp, type);

      case 'BLOCK':
        final children = _readList(comp['components']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((c) => _renderComponent(context, c, actions))
              .toList(),
        );

      case 'FIELD':
        return _renderField(context, comp, type);

      case 'ACTION':
        return _renderAction(context, comp, actions);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _renderDisplay(
      BuildContext context, Map<String, dynamic> comp, String type) {
    if (type == 'TEXT') {
      final label = _resolve(comp['label']);
      if (label.isEmpty) return const SizedBox.shrink();
      final variant = _str(comp['variant']);
      final style = variant == 'HEADING_1'
          ? Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)
          : Theme.of(context).textTheme.bodyMedium;
      final align = _str(comp['align']) == 'center'
          ? TextAlign.center
          : TextAlign.start;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(label, style: style, textAlign: align),
      );
    }
    // IMAGE: skip when src is an unresolved template
    if (type == 'IMAGE') {
      final src = _str(comp['src']);
      if (src.isEmpty || src.startsWith('{{')) return const SizedBox.shrink();
      final h = double.tryParse(_str(comp['height']));
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Image.network(src, height: h),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _renderField(
      BuildContext context, Map<String, dynamic> comp, String type) {
    final ref = _fieldRef(comp);
    if (ref.isEmpty) return const SizedBox.shrink();
    controllers.putIfAbsent(ref, TextEditingController.new);
    final isPassword = type.toLowerCase().contains('password');
    final label = _resolve(comp['label'], fallback: _capitalize(ref));
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controllers[ref],
        decoration: InputDecoration(
          labelText: label,
          hintText: _capitalize(ref),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: const OutlineInputBorder(),
        ),
        obscureText: isPassword,
        keyboardType: isPassword
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        autocorrect: false,
      ),
    );
  }

  Widget _renderAction(BuildContext context, Map<String, dynamic> comp,
      List<Map<String, dynamic>> actions) {
    final label = _resolve(comp['label'], fallback: 'Submit');
    // Meta can carry action references in either `ref` or `id` depending on source.
    final metaActionId = _str(comp['ref'], fallback: _str(comp['id']));
    final actionId = _findActionId(metaActionId, actions);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FilledButton(
        onPressed: state.isLoading
            ? null
            : () {
                if (kDebugMode) {
                  debugPrint('[B2C] submit pressed metaActionId=$metaActionId resolvedActionId=$actionId inputs=${controllers.keys.toList()}');
                }
                state.submit(
                  actionId,
                  controllers.map((k, v) => MapEntry(k, v.text)),
                );
              },
        child: state.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label),
      ),
    );
  }

  /// Finds the submit action id by matching [metaActionId] against
  /// [actions[].ref] if available, else returns the first action's id.
  String _findActionId(
      String metaActionId, List<Map<String, dynamic>> actions) {
    if (actions.isEmpty) return 'submit';

    final matchByRef = actions.firstWhere(
      (a) => _str(a['ref']) == metaActionId,
      orElse: () => const <String, dynamic>{},
    );
    if (matchByRef.isNotEmpty) {
      return _actionSubmitId(matchByRef);
    }

    final matchById = actions.firstWhere(
      (a) => _str(a['id']) == metaActionId,
      orElse: () => const <String, dynamic>{},
    );
    if (matchById.isNotEmpty) {
      return _actionSubmitId(matchById);
    }

    final index = _actionIndex(metaActionId);
    if (index != null && index >= 0 && index < actions.length) {
      return _actionSubmitId(actions[index]);
    }

    return _actionSubmitId(actions.first);
  }

  String _actionSubmitId(Map<String, dynamic> action) =>
      _str(action['ref'], fallback: _str(action['id'], fallback: _str(action['nextNode'], fallback: 'submit')));

  int? _actionIndex(String metaActionId) {
    if (!metaActionId.startsWith('action_')) return null;
    final raw = metaActionId.substring('action_'.length);
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed <= 0) return null;
    return parsed - 1;
  }

  // ── Fallback (no meta) ────────────────────────────────────────────────────

  List<Widget> _fallback(BuildContext context, Map<String, dynamic>? data,
      List<Map<String, dynamic>> actions) {
    final inputs = _readList(data?['inputs']);
    return [
      for (final input in inputs) ...[
        _renderField(
          context,
          {'ref': input['name'], 'label': '', 'type': input['type']},
          _str(input['type']),
        ),
      ],
      ...actions.map((action) => _renderAction(context, {
            'label': _str(action['label'], fallback: 'Submit'),
            'id': _str(action['id']),
          }, actions)),
      if (actions.isEmpty)
        _renderAction(context, {'label': 'Continue', 'id': 'init'}, actions),
    ];
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Resolves a value, returning [fallback] if it is an unresolved i18n
  /// template (`{{ ... }}`), empty, or not a String.
  String _resolve(dynamic value, {String fallback = ''}) {
    final s = value is String ? value.trim() : '';
    if (s.isEmpty) return fallback;
    final resolved = resolver?.resolve(s) ?? s;
    return resolved.isEmpty ? fallback : resolved;
  }

  String _str(dynamic v, {String fallback = ''}) =>
      (v is String && v.isNotEmpty) ? v : fallback;

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _fieldRef(Map<String, dynamic> comp) => _str(
        comp['ref'],
        fallback: _str(
          comp['identifier'],
          fallback: _str(
            comp['name'],
            fallback: _str(comp['id']),
          ),
        ),
      );

  String _inputRef(Map<String, dynamic> input) => _str(
        input['name'],
        fallback: _str(
          input['identifier'],
          fallback: _str(
            input['ref'],
            fallback: _str(input['id']),
          ),
        ),
      );

  Set<String> _componentFieldRefs(List<Map<String, dynamic>> components) {
    final refs = <String>{};

    void walk(List<Map<String, dynamic>> list) {
      for (final comp in list) {
        if (_effectiveCategory(comp) == 'FIELD') {
          final ref = _fieldRef(comp);
          if (ref.isNotEmpty) {
            refs.add(ref);
          }
        }

        final children = _readList(comp['components']);
        if (children.isNotEmpty) {
          walk(children);
        }
      }
    }

    walk(components);
    return refs;
  }

  bool _hasActionComponent(List<Map<String, dynamic>> components) {
    bool found = false;

    void walk(List<Map<String, dynamic>> list) {
      for (final comp in list) {
        if (_effectiveCategory(comp) == 'ACTION') {
          found = true;
          return;
        }
        final children = _readList(comp['components']);
        if (children.isNotEmpty) {
          walk(children);
          if (found) {
            return;
          }
        }
      }
    }

    walk(components);
    return found;
  }

  List<Map<String, dynamic>> _readList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry('$k', v)))
        .toList();
  }
}

String _decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return '(not a JWT)';
    final padded = parts[1].padRight((parts[1].length + 3) ~/ 4 * 4, '=');
    return utf8.decode(base64Url.decode(padded));
  } catch (e) {
    return '(decode error: $e)';
  }
}
