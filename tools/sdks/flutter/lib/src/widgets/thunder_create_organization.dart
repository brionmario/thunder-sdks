import 'package:flutter/widgets.dart';
import 'thunder_provider.dart';
import '../models/organization.dart';

/// Form to create a new organization (spec §8.4 Presentation).
class ThunderCreateOrganization extends StatelessWidget {
  final void Function(Organization org)? onCreated;
  final VoidCallback? onError;

  const ThunderCreateOrganization({super.key, this.onCreated, this.onError});

  @override
  Widget build(BuildContext context) {
    final state = ThunderProvider.of(context);
    return BaseThunderCreateOrganization(
      onCreated: onCreated,
      onError: onError,
      builder: (ctx, nameController, handleController, isLoading, error, create) =>
          Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(state.i18n.resolve('createOrganization.title')),
          const SizedBox(height: 16),
          if (error != null) ...[
            Text(error),
            const SizedBox(height: 8),
          ],
          Semantics(
            label: state.i18n.resolve('createOrganization.name'),
            child: SizedBox(
              height: 44,
              child: EditableText(
                controller: nameController,
                focusNode: FocusNode(),
                style: const TextStyle(fontSize: 16),
                cursorColor: const Color(0xFF000000),
                backgroundCursorColor: const Color(0xFF000000),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: state.i18n.resolve('createOrganization.handle'),
            child: SizedBox(
              height: 44,
              child: EditableText(
                controller: handleController,
                focusNode: FocusNode(),
                style: const TextStyle(fontSize: 16),
                cursorColor: const Color(0xFF000000),
                backgroundCursorColor: const Color(0xFF000000),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: isLoading ? null : create,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              child: Text(state.i18n.resolve('createOrganization.submit')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Unstyled base variant (spec §8.3).
class BaseThunderCreateOrganization extends StatefulWidget {
  final void Function(Organization org)? onCreated;
  final VoidCallback? onError;
  final Widget Function(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController handleController,
    bool isLoading,
    String? error,
    VoidCallback create,
  ) builder;

  const BaseThunderCreateOrganization({
    super.key,
    required this.builder,
    this.onCreated,
    this.onError,
  });

  @override
  State<BaseThunderCreateOrganization> createState() =>
      _BaseThunderCreateOrganizationState();
}

class _BaseThunderCreateOrganizationState
    extends State<BaseThunderCreateOrganization> {
  final _nameController = TextEditingController();
  final _handleController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final state = ThunderProvider.of(context);
      final org = await state.client.createOrganization(
        name: _nameController.text,
        handle: _handleController.text.isEmpty ? null : _handleController.text,
      );
      widget.onCreated?.call(org);
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
        _nameController,
        _handleController,
        _isLoading,
        _error,
        _create,
      );
}
