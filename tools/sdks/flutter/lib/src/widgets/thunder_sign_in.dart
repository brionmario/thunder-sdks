import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'thunder_provider.dart';
import 'flow_form.dart';
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
      builder: (ctx, signInState) => FlowForm(
        applicationId: applicationId,
        currentStep: signInState.currentStep,
        isLoading: signInState.isLoading,
        error: signInState.error,
        submit: signInState.submit,
        submitLabel: state.i18n.resolve('signIn.submit'),
      ),
    );
  }
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
    debugPrint('[ThunderSignIn] _submit flowId=$flowId actionId=$actionId inputs=${inputs.keys.toList()}');
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
    } catch (e, st) {
      debugPrint('[ThunderSignIn] _submit error: $e\n$st');
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
