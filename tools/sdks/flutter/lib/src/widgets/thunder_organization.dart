import 'package:flutter/widgets.dart';
import 'thunder_provider.dart';
import '../models/organization.dart';

/// Read-only display of the current organization (spec §8.4 Presentation).
class ThunderOrganization extends StatelessWidget {
  const ThunderOrganization({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ThunderProvider.of(context);
    return BaseThunderOrganization(
      builder: (ctx, org) => org != null
          ? Semantics(label: org.name, child: Text(org.name))
          : Text(state.i18n.resolve('organization.unnamed')),
    );
  }
}

/// Unstyled base variant (spec §8.3).
class BaseThunderOrganization extends StatefulWidget {
  final Widget Function(BuildContext context, Organization? organization) builder;

  const BaseThunderOrganization({super.key, required this.builder});

  @override
  State<BaseThunderOrganization> createState() => _BaseThunderOrganizationState();
}

class _BaseThunderOrganizationState extends State<BaseThunderOrganization> {
  Organization? _org;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = ThunderProvider.of(context);
    final org = await state.client.getCurrentOrganization();
    if (mounted) setState(() => _org = org);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _org);
}
