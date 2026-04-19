import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'thunder_provider.dart';
import '../models/flow_models.dart';
import '../models/token_exchange_config.dart';
import '../models/user.dart';

/// State exposed to [BaseThunderSignIn]'s builder.
class ThunderSignInState {
  final EmbeddedFlowResponse? currentStep;
  final bool isLoading;
  final String? error;
  final Future<void> Function(String actionId, Map<String, String> inputs) submit;

  const ThunderSignInState({
    required this.currentStep,
    required this.isLoading,
    required this.error,
    required this.submit,
  });
}

/// Full sign-in form that drives the Flow Execution API loop (spec §8.4 Presentation).
/// Renders each step's inputs dynamically based on server-reported [FlowStepData].
class ThunderSignIn extends StatelessWidget {
  final String applicationId;
  final void Function(User user)? onSuccess;
  final VoidCallback? onError;

  const ThunderSignIn({
    super.key,
    required this.applicationId,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final state = ThunderProvider.of(context);
    return BaseThunderSignIn(
      applicationId: applicationId,
      onSuccess: onSuccess,
      onError: onError,
      builder: (ctx, signInState) => _DefaultSignInLayout(
        signInState: signInState,
        i18n: state.i18n,
      ),
    );
  }
}

class _DefaultSignInLayout extends StatefulWidget {
  final ThunderSignInState signInState;
  final dynamic i18n;

  const _DefaultSignInLayout({required this.signInState, required this.i18n});

  @override
  State<_DefaultSignInLayout> createState() => _DefaultSignInLayoutState();
}

class _DefaultSignInLayoutState extends State<_DefaultSignInLayout> {
  final _controllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.signInState;
    final inputs = _readMapList(s.currentStep?.data?['inputs']);
    final actions = _readMapList(s.currentStep?.data?['actions']);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.i18n.resolve('signIn.title')),
        const SizedBox(height: 16),
        for (final input in inputs) ...[
          Semantics(
            label: _fieldKey(input),
            child: _buildFieldGroup(input),
          ),
          const SizedBox(height: 12),
        ],
        if (s.error != null) ...[
          Text(s.error!),
          const SizedBox(height: 8),
        ],
        for (final action in actions)
          GestureDetector(
            onTap: s.isLoading
                ? null
                : () => s.submit(
                      _actionId(action),
                      _controllers.map((k, v) => MapEntry(k, v.text)),
                    ),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              child: Text(_stringOr(action['label'], fallback: widget.i18n.resolve('signIn.submit'))),
            ),
          ),
        if (actions.isEmpty && !s.isLoading)
          GestureDetector(
            onTap: () => s.submit(
              'init',
              _controllers.map((k, v) => MapEntry(k, v.text)),
            ),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              child: Text(widget.i18n.resolve('signIn.submit')),
            ),
          ),
      ],
    );
  }

  String _fieldKey(Map<String, dynamic> input) =>
      _stringOr(
        input['identifier'] ?? input['name'] ?? input['ref'] ?? input['id'],
        fallback: 'input',
      );

  Widget _buildFieldGroup(Map<String, dynamic> input) {
    final key = _fieldKey(input);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          key,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4A4A58)),
        ),
        const SizedBox(height: 6),
        _buildField(input),
      ],
    );
  }

  Widget _buildField(Map<String, dynamic> input) {
    final name = _fieldKey(input);
    _controllers.putIfAbsent(name, TextEditingController.new);
    final isPassword = _stringOr(input['type']).toLowerCase().contains('password');
    return _SimpleTextField(
      controller: _controllers[name]!,
      placeholder: name,
      obscureText: isPassword,
    );
  }

  List<Map<String, dynamic>> _readMapList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry('$k', v)))
        .toList(growable: false);
  }

  String _stringOr(dynamic value, {String fallback = ''}) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return fallback;
  }

  String _actionId(Map<String, dynamic> action) {
    return _stringOr(
      action['ref'],
      fallback: _stringOr(
        action['id'],
        fallback: _stringOr(action['nextNode'], fallback: 'submit'),
      ),
    );
  }
}

class _SimpleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool obscureText;

  const _SimpleTextField({
    required this.controller,
    required this.placeholder,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: placeholder,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: const OutlineInputBorder(),
        ),
      );
}

/// Unstyled base variant. [builder] receives [ThunderSignInState] to render any UI (spec §8.3).
class BaseThunderSignIn extends StatefulWidget {
  final String applicationId;
  final void Function(User user)? onSuccess;
  final VoidCallback? onError;
  final Widget Function(BuildContext context, ThunderSignInState state) builder;

  const BaseThunderSignIn({
    super.key,
    required this.applicationId,
    required this.builder,
    this.onSuccess,
    this.onError,
  });

  @override
  State<BaseThunderSignIn> createState() => _BaseThunderSignInState();
}

class _BaseThunderSignInState extends State<BaseThunderSignIn> {
  EmbeddedFlowResponse? _currentStep;
  bool _isLoading = false;
  String? _error;
  bool _autoAdvancing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_initFlow);
  }

  Future<void> _initFlow() async {
    setState(() => _isLoading = true);
    try {
      final state = ThunderProvider.of(context);
      final response = await state.client.signIn(
        payload: EmbeddedSignInPayload(actionId: 'init'),
        request: EmbeddedFlowRequestConfig(applicationId: widget.applicationId),
      );
      if (kDebugMode) {
        final inputList = (response.data?['inputs'] as List?) ?? const [];
        final actionList = (response.data?['actions'] as List?) ?? const [];
        debugPrint('[ThunderSignIn] init response flowStatus=${response.flowStatus} inputs=$inputList actions=$actionList');
      }
      if (mounted) setState(() { _currentStep = response; _error = null; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      widget.onError?.call();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit(String actionId, Map<String, String> inputs) async {
    final flowId = _currentStep?.flowId;
    if (flowId == null) return;
    setState(() => _isLoading = true);
    try {
      final state = ThunderProvider.of(context);
      var response = await state.client.signIn(
        payload: EmbeddedSignInPayload(flowId: flowId, actionId: actionId, inputs: inputs),
        request: EmbeddedFlowRequestConfig(applicationId: widget.applicationId),
      );

      if (_shouldAutoAdvance(response)) {
        _autoAdvancing = true;
        final nextActionId = _nextActionId(response);
        if (nextActionId.isNotEmpty && response.flowId != null) {
          if (kDebugMode) {
            debugPrint('[ThunderSignIn] auto-advancing actionId=$nextActionId');
          }
          response = await state.client.signIn(
            payload: EmbeddedSignInPayload(
              flowId: response.flowId,
              actionId: nextActionId,
              inputs: const {},
            ),
            request: EmbeddedFlowRequestConfig(applicationId: widget.applicationId),
          );
        }
      }

      if (kDebugMode) {
        final hasAssertion = response.assertion?.isNotEmpty ?? false;
        final inputCount = (response.data?['inputs'] as List?)?.length ?? 0;
        final actionCount = (response.data?['actions'] as List?)?.length ?? 0;
        final inputList = (response.data?['inputs'] as List?) ?? const [];
        final actionList = (response.data?['actions'] as List?) ?? const [];
        debugPrint('[ThunderSignIn] submit response flowStatus=${response.flowStatus} hasAssertion=$hasAssertion inputs=$inputCount actions=$actionCount failureReason=${response.failureReason}');
        debugPrint('[ThunderSignIn] submit response inputData=$inputList actionData=$actionList');
      }
      final isComplete = response.flowStatus == FlowStatus.complete ||
          (response.assertion?.isNotEmpty ?? false);
      if (isComplete) {
        if (mounted) {
          setState(() {
            _currentStep = response;
            _error = null;
          });
        }
        final assertion = response.assertion;
        if (assertion != null && assertion.isNotEmpty) {
          final signedIn = await state.client.isSignedIn();
          if (!signedIn) {
            await state.client.exchangeToken(
              TokenExchangeRequestConfig(
                subjectToken: assertion,
                subjectTokenType: 'urn:ietf:params:oauth:token-type:jwt',
              ),
            );
          }
        }
        await state.refresh();
        if (mounted) {
          final user = state.user;
          if (user != null) {
            widget.onSuccess?.call(user);
          } else {
            setState(() => _error = 'Sign-in completed, but session was not established.');
            widget.onError?.call();
          }
        }
      } else if (response.flowStatus == FlowStatus.error) {
        if (mounted) setState(() => _error = response.failureReason ?? 'Authentication failed');
        widget.onError?.call();
      } else {
        if (mounted) setState(() { _currentStep = response; _error = null; });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      widget.onError?.call();
    } finally {
      _autoAdvancing = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _shouldAutoAdvance(EmbeddedFlowResponse response) {
    if (_autoAdvancing) return false;
    if (response.flowStatus != FlowStatus.promptOnly) return false;
    final data = response.data;
    if (data == null) return false;

    final inputs = data['inputs'];
    final actions = data['actions'];
    final inputCount = inputs is List ? inputs.length : 0;
    final actionCount = actions is List ? actions.length : 0;
    return inputCount == 0 && actionCount == 1;
  }

  String _nextActionId(EmbeddedFlowResponse response) {
    final data = response.data;
    if (data == null) return '';
    final actions = data['actions'];
    if (actions is! List || actions.isEmpty) return '';
    final first = actions.first;
    if (first is! Map) return '';
    final ref = first['ref'];
    if (ref is String && ref.isNotEmpty) return ref;

    final id = first['id'];
    if (id is String && id.isNotEmpty) return id;

    final nextNode = first['nextNode'];
    return nextNode is String ? nextNode : '';
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        ThunderSignInState(
          currentStep: _currentStep,
          isLoading: _isLoading,
          error: _error,
          submit: _submit,
        ),
      );
}
