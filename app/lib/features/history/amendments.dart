import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/application.dart';

/// A correction recorded against a signed application. The application
/// row itself is NEVER updated — amendments are the audit trail.
class AmendmentModel {
  const AmendmentModel({
    required this.id,
    required this.fieldName,
    this.oldValue,
    required this.newValue,
    required this.reason,
    this.authorId,
    this.createdAt,
  });

  final String id;
  final String fieldName;
  final String? oldValue;
  final String newValue;
  final String reason;
  final String? authorId;
  final DateTime? createdAt;

  factory AmendmentModel.fromSnakeJson(Map<String, dynamic> json) {
    return AmendmentModel(
      id: json['id'] as String,
      fieldName: json['field_name'] as String? ?? '',
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      authorId: json['author_id'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal(),
    );
  }
}

/// Amendments for one record, newest first. Empty on any error (offline).
final amendmentsProvider =
    FutureProvider.family<List<AmendmentModel>, String>((ref, applicationId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final rows = await client
        .from('amendments')
        .select()
        .eq('application_id', applicationId)
        .order('created_at', ascending: false);
    return [for (final row in rows) AmendmentModel.fromSnakeJson(row)];
  } catch (_) {
    return const [];
  }
});

/// Fields that may be amended through the dialog.
const amendableFields = [
  'rate_value',
  'area_value',
  'target_pest',
  'application_method',
];

String _currentValue(ApplicationModel record, String field) {
  return switch (field) {
    'rate_value' => record.rateValue.toString(),
    'area_value' => record.areaValue.toString(),
    'target_pest' => record.targetPest ?? '',
    'application_method' => record.applicationMethod ?? '',
    _ => '',
  };
}

/// Amend modal: field dropdown, prefilled old value, new value, required
/// reason. Inserts into `amendments` only — the application row is never
/// touched. Returns true when an amendment was saved.
Future<bool> showAmendDialog(
  BuildContext context,
  WidgetRef ref,
  ApplicationModel record,
) async {
  final profile = await ref.read(currentProfileProvider.future);
  if (profile == null || !context.mounted) return false;

  var field = amendableFields.first;
  final oldController =
      TextEditingController(text: _currentValue(record, field));
  final newController = TextEditingController();
  final reasonController = TextEditingController();
  var busy = false;
  String? error;

  final saved = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> save() async {
            if (newController.text.trim().isEmpty ||
                reasonController.text.trim().isEmpty) {
              setDialogState(
                () => error = 'New value and reason are required',
              );
              return;
            }
            setDialogState(() {
              busy = true;
              error = null;
            });
            try {
              await ref.read(supabaseClientProvider).from('amendments').insert({
                'company_id': profile.companyId,
                'application_id': record.id,
                'field_name': field,
                'old_value': oldController.text.trim(),
                'new_value': newController.text.trim(),
                'reason': reasonController.text.trim(),
                'author_id': profile.id,
              });
              if (context.mounted) Navigator.of(context).pop(true);
            } catch (e) {
              setDialogState(() {
                busy = false;
                error = 'Failed to save amendment: $e';
              });
            }
          }

          return AlertDialog(
            title: const Text('Amend record'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: field,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Field'),
                  items: [
                    for (final option in amendableFields)
                      DropdownMenuItem(value: option, child: Text(option)),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() {
                      field = value;
                      oldController.text = _currentValue(record, field);
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: oldController,
                  decoration: const InputDecoration(labelText: 'Old value'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  decoration: const InputDecoration(labelText: 'New value'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration:
                      const InputDecoration(labelText: 'Reason (required)'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: busy ? null : save,
                child: Text(busy ? 'Saving…' : 'Save amendment'),
              ),
            ],
          );
        },
      );
    },
  );

  if (saved == true) {
    ref.invalidate(amendmentsProvider(record.id));
    return true;
  }
  return false;
}

/// Read-only amendments list for the record, newest first.
class AmendmentsSection extends ConsumerWidget {
  const AmendmentsSection({required this.applicationId, super.key});

  final String applicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amendments =
        ref.watch(amendmentsProvider(applicationId)).valueOrNull ?? const [];
    if (amendments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SectionHeader('Amendments'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final amendment in amendments)
                ListTile(
                  dense: true,
                  title: Text(
                    '${amendment.fieldName}: '
                    '${amendment.oldValue ?? '—'} → ${amendment.newValue}',
                  ),
                  subtitle: Text(
                    [
                      amendment.reason,
                      if (amendment.createdAt != null)
                        DateFormat('yyyy-MM-dd HH:mm')
                            .format(amendment.createdAt!),
                    ].join(' · '),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
