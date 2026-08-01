import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/widgets/section_header.dart';
import '../billing/billing_service.dart';
import '../billing/plan_status.dart';

/// Company row for the settings Company section.
final _companyInfoProvider = FutureProvider<Map<String, dynamic>?>(
  (ref) async {
    final profile = await ref.watch(currentProfileProvider.future);
    if (profile == null || profile.companyId.isEmpty) return null;
    try {
      return await ref
          .watch(supabaseClientProvider)
          .from('companies')
          .select('name, operating_states, timezone')
          .eq('id', profile.companyId)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  },
);

/// Applicator profile in this company.
class ApplicatorModel {
  const ApplicatorModel({
    required this.id,
    required this.fullName,
    this.role,
    this.licenseNumber,
    this.licenseState,
    this.licenseExpiresAt,
  });

  final String id;
  final String fullName;
  final String? role;
  final String? licenseNumber;
  final String? licenseState;
  final DateTime? licenseExpiresAt;

  factory ApplicatorModel.fromSnakeJson(Map<String, dynamic> json) {
    return ApplicatorModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String?,
      licenseNumber: json['license_number'] as String?,
      licenseState: json['license_state'] as String?,
      licenseExpiresAt:
          DateTime.tryParse(json['license_expires_at'] as String? ?? '')
              ?.toLocal(),
    );
  }

  /// License expired or within 30 days of expiring.
  bool get licenseExpiringSoon {
    final expiry = licenseExpiresAt;
    if (expiry == null) return false;
    return expiry.isBefore(DateTime.now().add(const Duration(days: 30)));
  }
}

final _applicatorsProvider = FutureProvider<List<ApplicatorModel>>(
  (ref) async {
    final profile = await ref.watch(currentProfileProvider.future);
    if (profile == null || profile.companyId.isEmpty) return const [];
    try {
      final rows = await ref
          .watch(supabaseClientProvider)
          .from('profiles')
          .select(
            'id, full_name, role, license_number, license_state, license_expires_at',
          )
          .eq('company_id', profile.companyId)
          .order('full_name');
      return [for (final row in rows) ApplicatorModel.fromSnakeJson(row)];
    } catch (_) {
      return const [];
    }
  },
);

/// Settings: company info, plan/subscription, applicators & seats.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(_companyInfoProvider).valueOrNull;
    final plan = ref.watch(planStatusProvider).valueOrNull;
    final applicators = ref.watch(_applicatorsProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Company'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Name'),
                  trailing: Text(
                    company?['name'] as String? ?? '—',
                  ),
                ),
                ListTile(
                  title: const Text('Operating states'),
                  trailing: Text(
                    (company?['operating_states'] as List?)
                            ?.whereType<String>()
                            .join(', ') ??
                        '—',
                  ),
                ),
                ListTile(
                  title: const Text('Timezone'),
                  trailing: Text(company?['timezone'] as String? ?? '—'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader('Plan'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Plan'),
                  trailing: Text(plan?.planDisplayName ?? '—'),
                ),
                ListTile(
                  title: const Text('Status'),
                  trailing: Text(
                    plan == null || plan.status.isEmpty ? '—' : plan.status,
                  ),
                ),
                if (plan?.trialEndsAt != null)
                  ListTile(
                    title: const Text('Trial ends'),
                    trailing: Text(
                      DateFormat('yyyy-MM-dd').format(plan!.trialEndsAt!),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            showSubscriptionPaywall(context, ref),
                        child: const Text('Manage subscription'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Self-serve checkout arrives with the store keys.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader('Applicators'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                if (applicators == null)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (applicators.isEmpty)
                  const ListTile(title: Text('No applicators found.'))
                else
                  for (final applicator in applicators)
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: Text(applicator.fullName),
                      subtitle: Text(
                        [
                          if (applicator.licenseNumber != null)
                            'License ${applicator.licenseNumber}',
                          if (applicator.licenseState != null)
                            applicator.licenseState!,
                          if (applicator.licenseExpiresAt != null)
                            'expires ${DateFormat('yyyy-MM-dd').format(applicator.licenseExpiresAt!)}',
                        ].join(' · '),
                      ),
                      subtitleTextStyle: applicator.licenseExpiringSoon
                          ? TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            )
                          : null,
                    ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _showAddApplicator(context, ref),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add applicator'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddApplicator(BuildContext context, WidgetRef ref) async {
    final userIdController = TextEditingController();
    final nameController = TextEditingController();
    final licenseNumberController = TextEditingController();
    final licenseStateController = TextEditingController();
    var busy = false;
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              final targetUserId = userIdController.text.trim();
              final fullName = nameController.text.trim();
              if (targetUserId.isEmpty || fullName.isEmpty) {
                setDialogState(
                  () => error = 'User id and full name are required',
                );
                return;
              }
              setDialogState(() {
                busy = true;
                error = null;
              });
              try {
                await ref.read(supabaseClientProvider).rpc(
                  'add_applicator',
                  params: {
                    'target_user_id': targetUserId,
                    'new_full_name': fullName,
                    'new_license_number':
                        licenseNumberController.text.trim().isEmpty
                            ? null
                            : licenseNumberController.text.trim(),
                    'new_license_state':
                        licenseStateController.text.trim().isEmpty
                            ? null
                            : licenseStateController.text.trim().toUpperCase(),
                  },
                );
                if (context.mounted) Navigator.of(context).pop(true);
              } catch (e) {
                final message = e.toString();
                setDialogState(() {
                  busy = false;
                  if (message.contains('seat_limit')) {
                    final seats =
                        RegExp(r'seat_limit[^\d]*(\d+)')
                            .firstMatch(message)
                            ?.group(1);
                    error = seats != null
                        ? 'Plan allows $seats applicators — upgrade to add more'
                        : 'Plan seat limit reached — upgrade to add more';
                  } else {
                    error = 'Failed to add applicator: $message';
                  }
                });
              }
            }

            return AlertDialog(
              title: const Text('Add applicator'),
              content: ListView(
                shrinkWrap: true,
                children: [
                  TextField(
                    controller: userIdController,
                    decoration: const InputDecoration(
                      labelText: 'User id (auth)',
                      hintText: 'uuid of their auth account',
                      helperText:
                          'Self-serve invites come later — ask them to sign '
                          'up first, then paste their user id here.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: licenseNumberController,
                    decoration:
                        const InputDecoration(labelText: 'License number'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: licenseStateController,
                    decoration: const InputDecoration(
                      labelText: 'License state',
                      counterText: '',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 2,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      busy ? null : () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: busy ? null : save,
                  child: Text(busy ? 'Adding…' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      ref.invalidate(_applicatorsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Applicator added.')),
        );
      }
    }
  }
}
