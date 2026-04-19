import 'package:flutter/widgets.dart';
import 'thunder_provider.dart';
import '../models/flow_models.dart';
import '../models/token_exchange_config.dart';

/// Full registration form driving the REGISTRATION flow (spec §8.4 Presentation).
class ThunderSignUp extends StatelessWidget {
  final String applicationId;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const ThunderSignUp({super.key, required this.applicationId, this.onSuccess, this.onError});

  @override
  Widget build(BuildContext context) {
    final state = ThunderProvider.of(context);
    return BaseThunderSignUp(
      applicationId: applicationId,
      onSuccess: onSuccess,
      onError: onError,
      builder: (ctx, flowState) => _DefaultSignUpLayout(
        flowState: flowState,
        label: state.i18n.resolve('signUp.submit'),
        title: state.i18n.resolve('signUp.title'),
        errorFallback: state.i18n.resolve('signUp.error.generic'),
      ),
    );
  }
}

class _DefaultSignUpLayout extends StatefulWidget {
  final _FlowState flowState;
  final String label;
  final String title;
  final String errorFallback;

  const _DefaultSignUpLayout({
    required this.flowState,
    required this.label,
    required this.title,
    required this.errorFallback,
  });

  @override
  State<_DefaultSignUpLayout> createState() => _DefaultSignUpLayoutState();
}

class _DefaultSignUpLayoutState extends State<_DefaultSignUpLayout> {
  final _controllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.flowState;
    final inputs = _readMapList(s.currentStep?.data?['inputs']);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.title),
        const SizedBox(height: 16),
        for (final input in inputs) ...[
          _buildField(input),
          const SizedBox(height: 12),
        ],
        if (s.error != null) Text(s.error!),
        GestureDetector(
          onTap: s.isLoading
              ? null
              : () => s.submit(
                      _firstActionId(s.currentStep?.data),
                    _controllers.map((k, v) => MapEntry(k, v.text)),
                  ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            child: Text(widget.label),
          ),
        ),
      ],
    );
  }

  Widget _buildField(Map<String, dynamic> input) {
    final name = _stringOr(input['name']);
    _controllers.putIfAbsent(name, TextEditingController.new);
    return SizedBox(
      height: 44,
      child: EditableText(
        controller: _controllers[name]!,
        focusNode: FocusNode(),
        style: const TextStyle(fontSize: 16),
        cursorColor: const Color(0xFF000000),
        backgroundCursorColor: const Color(0xFF000000),
        obscureText: _stringOr(input['type']).toLowerCase() == 'password',
      ),
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

  String _firstActionId(Map<String, dynamic>? data) {
    final actions = _readMapList(data?['actions']);
    if (actions.isEmpty) {
      return 'submit';
    }
    return _actionId(actions.first);
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

  String _stringOr(dynamic value, {String fallback = ''}) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return fallback;
  }
}

class _FlowState {
  final EmbeddedFlowResponse? currentStep;
  final bool isLoading;
  final String? error;
  final Future<void> Function(String actionId, Map<String, String> inputs) submit;

  const _FlowState({
    required this.currentStep,
    required this.isLoading,
    required this.error,
    required this.submit,
  });
}

/// Unstyled base variant (spec §8.3).
class BaseThunderSignUp extends StatefulWidget {
  final String applicationId;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final Widget Function(BuildContext context, _FlowState state) builder;

  const BaseThunderSignUp({
    super.key,
    required this.applicationId,
    required this.builder,
    this.onSuccess,
    this.onError,
  });

  @override
  State<BaseThunderSignUp> createState() => _BaseThunderSignUpState();
}

class _BaseThunderSignUpState extends State<BaseThunderSignUp> {
  EmbeddedFlowResponse? _currentStep;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_initFlow);
  }

  Future<void> _initFlow() async {
    setState(() => _isLoading = true);
    try {
      final state = ThunderProvider.of(context);
      final response = await state.client.signUp(
        request: EmbeddedFlowRequestConfig(
          applicationId: widget.applicationId,
          flowType: FlowType.registration,
        ),
      );
      if (mounted) setState(() { _currentStep = response; _error = null; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
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
      final response = await state.client.signUp(
        payload: EmbeddedSignInPayload(flowId: flowId, actionId: actionId, inputs: inputs),
        request: EmbeddedFlowRequestConfig(
          applicationId: widget.applicationId,
          flowType: FlowType.registration,
        ),
      );
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
        widget.onSuccess?.call();
      } else if (response.flowStatus == FlowStatus.error) {
        if (mounted) setState(() => _error = response.failureReason ?? 'Registration failed');
        widget.onError?.call();
      } else {
        if (mounted) setState(() { _currentStep = response; _error = null; });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      widget.onError?.call();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _FlowState(
          currentStep: _currentStep,
          isLoading: _isLoading,
          error: _error,
          submit: _submit,
        ),
      );
}
