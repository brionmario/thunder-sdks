import 'package:flutter/widgets.dart';
import 'thunderid_provider.dart';
import '../models/organization.dart';

/// Displays and optionally edits the current organization's details (spec §8.4 Presentation).
class ThunderIDOrganizationProfile extends StatelessWidget {
  const ThunderIDOrganizationProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseThunderIDOrganizationProfile(
      builder: (ctx, org, isLoading, error) {
        if (isLoading) return const SizedBox.shrink();
        if (org == null || error != null) return Text(error ?? '');
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(label: org.name, child: Text(org.name)),
            if (org.handle != null) Text(org.handle!),
          ],
        );
      },
    );
  }
}

/// Unstyled base variant (spec §8.3).
class BaseThunderIDOrganizationProfile extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    Organization? organization,
    bool isLoading,
    String? error,
  ) builder;

  const BaseThunderIDOrganizationProfile({super.key, required this.builder});

  @override
  State<BaseThunderIDOrganizationProfile> createState() => _BaseThunderIDOrganizationProfileState();
}

class _BaseThunderIDOrganizationProfileState extends State<BaseThunderIDOrganizationProfile> {
  Organization? _org;
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
      final state = ThunderIDProvider.of(context);
      final org = await state.client.getCurrentOrganization();
      if (mounted) setState(() => _org = org);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _org, _isLoading, _error);
}
