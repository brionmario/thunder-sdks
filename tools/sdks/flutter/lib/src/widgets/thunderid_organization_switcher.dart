import 'package:flutter/widgets.dart';
import 'thunderid_provider.dart';
import '../models/organization.dart';

/// Dropdown to switch the signed-in user's active organization (spec §8.4 Presentation).
class ThunderIDOrganizationSwitcher extends StatelessWidget {
  const ThunderIDOrganizationSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ThunderIDProvider.of(context);
    return BaseThunderIDOrganizationSwitcher(
      builder: (ctx, orgs, current, isSwitching, error, switchOrg) {
        if (orgs.isEmpty) return Text(state.i18n.resolve('organizationSwitcher.empty'));
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final org in orgs)
              GestureDetector(
                onTap: isSwitching ? null : () => switchOrg(org),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Semantics(
                    label: org.name,
                    selected: org.id == current?.id,
                    button: true,
                    child: Text(
                      org.name,
                      style: TextStyle(
                        fontWeight: org.id == current?.id
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            if (error != null) Text(error),
          ],
        );
      },
    );
  }
}

/// Unstyled base variant (spec §8.3).
class BaseThunderIDOrganizationSwitcher extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    List<Organization> organizations,
    Organization? currentOrganization,
    bool isSwitching,
    String? error,
    Future<void> Function(Organization) switchOrganization,
  ) builder;

  const BaseThunderIDOrganizationSwitcher({super.key, required this.builder});

  @override
  State<BaseThunderIDOrganizationSwitcher> createState() =>
      _BaseThunderIDOrganizationSwitcherState();
}

class _BaseThunderIDOrganizationSwitcherState
    extends State<BaseThunderIDOrganizationSwitcher> {
  List<Organization> _orgs = [];
  Organization? _current;
  bool _isSwitching = false;
  String? _error;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted && ThunderIDProvider.of(context).initialized) {
      _loadStarted = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _isSwitching = true);
    try {
      final state = ThunderIDProvider.of(context);
      final results = await Future.wait([
        state.client.getMyOrganizations(),
        state.client.getCurrentOrganization(),
      ]);
      if (mounted) {
        setState(() {
          _orgs = results[0] as List<Organization>;
          _current = results[1] as Organization?;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSwitching = false);
    }
  }

  Future<void> _switch(Organization org) async {
    setState(() { _isSwitching = true; _error = null; });
    try {
      final state = ThunderIDProvider.of(context);
      await state.client.switchOrganization(org);
      if (mounted) setState(() => _current = org);
      await ThunderIDProvider.of(context).refresh();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSwitching = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _orgs, _current, _isSwitching, _error, _switch);
}
