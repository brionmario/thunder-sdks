import 'package:flutter/widgets.dart';
import 'thunderid_provider.dart';
import '../models/flow_models.dart';
import '../models/token_exchange_config.dart';

/// UI for accepting an admin-sent invitation (spec §8.4 Presentation).
/// Initiates the INVITED_USER_REGISTRATION flow with the provided [invitationCode].
class ThunderIDAcceptInvite extends StatelessWidget {
  final String invitationCode;
  final String applicationId;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const ThunderIDAcceptInvite({
    super.key,
    required this.invitationCode,
    required this.applicationId,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final state = ThunderIDProvider.of(context);
    return BaseThunderIDAcceptInvite(
      invitationCode: invitationCode,
      applicationId: applicationId,
      onSuccess: onSuccess,
      onError: onError,
      builder: (ctx, isLoading, error, onAccept) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(state.i18n.resolve('acceptInvite.title')),
          if (error != null) Text(error),
          GestureDetector(
            onTap: isLoading ? null : onAccept,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              child: Text(state.i18n.resolve('acceptInvite.submit')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Unstyled base variant (spec §8.3).
class BaseThunderIDAcceptInvite extends StatefulWidget {
  final String invitationCode;
  final String applicationId;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final Widget Function(BuildContext context, bool isLoading, String? error, VoidCallback onAccept) builder;

  const BaseThunderIDAcceptInvite({
    super.key,
    required this.invitationCode,
    required this.applicationId,
    required this.builder,
    this.onSuccess,
    this.onError,
  });

  @override
  State<BaseThunderIDAcceptInvite> createState() => _BaseThunderIDAcceptInviteState();
}

class _BaseThunderIDAcceptInviteState extends State<BaseThunderIDAcceptInvite> {
  bool _isLoading = false;
  String? _error;

  Future<void> _accept() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final state = ThunderIDProvider.of(context);
      EmbeddedFlowResponse? step = await state.client.signUp(
        request: EmbeddedFlowRequestConfig(
          applicationId: widget.applicationId,
          flowType: FlowType.invitedUserRegistration,
        ),
      );
      // Submit invitation code as first input
      if (step.flowId != null) {
        final actions = (step.data?['actions'] as List?)
                ?.whereType<Map>()
                .map((m) => m.map((k, v) => MapEntry('$k', v)))
                .toList() ??
            const <Map<String, dynamic>>[];
        step = await state.client.signUp(
          payload: EmbeddedSignInPayload(
            flowId: step.flowId,
            actionId: actions.isNotEmpty ? (actions.first['id'] as String? ?? 'submit') : 'submit',
            inputs: {'invitationCode': widget.invitationCode},
          ),
          request: EmbeddedFlowRequestConfig(
            applicationId: widget.applicationId,
            flowType: FlowType.invitedUserRegistration,
          ),
        );
      }
      if (step.flowStatus == FlowStatus.complete) {
        final assertion = step.assertion;
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
      } else {
        if (mounted) setState(() => _error = step?.failureReason ?? 'Failed to accept invitation');
        widget.onError?.call();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      widget.onError?.call();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _isLoading, _error, _accept);
}
