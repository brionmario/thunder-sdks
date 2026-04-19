import 'package:flutter/widgets.dart';
import 'thunder_provider.dart';
import '../models/organization.dart';

/// Lists organizations the signed-in user belongs to (spec §8.4 Presentation).
class ThunderOrganizationList extends StatelessWidget {
  final void Function(Organization org)? onOrganizationTap;

  const ThunderOrganizationList({super.key, this.onOrganizationTap});

  @override
  Widget build(BuildContext context) {
    final state = ThunderProvider.of(context);
    return BaseThunderOrganizationList(
      onOrganizationTap: onOrganizationTap,
      builder: (ctx, orgs, isLoading, error) {
        if (isLoading) return const SizedBox.shrink();
        if (orgs.isEmpty) return Text(state.i18n.resolve('organizationList.empty'));
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final org in orgs)
              GestureDetector(
                onTap: () => onOrganizationTap?.call(org),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Semantics(label: org.name, child: Text(org.name)),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Unstyled base variant (spec §8.3).
class BaseThunderOrganizationList extends StatefulWidget {
  final void Function(Organization org)? onOrganizationTap;
  final Widget Function(
    BuildContext context,
    List<Organization> organizations,
    bool isLoading,
    String? error,
  ) builder;

  const BaseThunderOrganizationList({
    super.key,
    required this.builder,
    this.onOrganizationTap,
  });

  @override
  State<BaseThunderOrganizationList> createState() => _BaseThunderOrganizationListState();
}

class _BaseThunderOrganizationListState extends State<BaseThunderOrganizationList> {
  List<Organization> _orgs = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final state = ThunderProvider.of(context);
      final orgs = await state.client.getMyOrganizations();
      if (mounted) setState(() => _orgs = orgs);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _orgs, _isLoading, _error);
}
