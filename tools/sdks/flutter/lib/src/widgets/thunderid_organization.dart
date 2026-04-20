import 'package:flutter/widgets.dart';
import 'thunderid_provider.dart';
import '../models/organization.dart';

/// Read-only display of the current organization (spec §8.4 Presentation).
class ThunderIDOrganization extends StatelessWidget {
  const ThunderIDOrganization({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ThunderIDProvider.of(context);
    return BaseThunderIDOrganization(
      builder: (ctx, org) => org != null
          ? Semantics(label: org.name, child: Text(org.name))
          : Text(state.i18n.resolve('organization.unnamed')),
    );
  }
}

/// Unstyled base variant (spec §8.3).
class BaseThunderIDOrganization extends StatefulWidget {
  final Widget Function(BuildContext context, Organization? organization) builder;

  const BaseThunderIDOrganization({super.key, required this.builder});

  @override
  State<BaseThunderIDOrganization> createState() => _BaseThunderIDOrganizationState();
}

class _BaseThunderIDOrganizationState extends State<BaseThunderIDOrganization> {
  Organization? _org;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = ThunderIDProvider.of(context);
    final org = await state.client.getCurrentOrganization();
    if (mounted) setState(() => _org = org);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _org);
}
