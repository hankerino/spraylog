import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/result.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/application.dart';
import '../../data/repositories/customers_repository.dart';

/// A customer notice sent for a record (email via the send-notice edge
/// function; delivery tracked on the `notices` table).
class NoticeModel {
  const NoticeModel({
    required this.id,
    this.channel,
    this.destination,
    this.deliveryStatus,
    this.sentAt,
  });

  final String id;
  final String? channel;
  final String? destination;
  final String? deliveryStatus;
  final DateTime? sentAt;

  factory NoticeModel.fromSnakeJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] as String,
      channel: json['channel'] as String?,
      destination: json['destination'] as String?,
      deliveryStatus: json['delivery_status'] as String?,
      sentAt:
          DateTime.tryParse(json['sent_at'] as String? ?? '')?.toLocal(),
    );
  }
}

/// Notices for one record, newest first. Empty on any error (offline).
final noticesProvider =
    FutureProvider.family<List<NoticeModel>, String>((ref, applicationId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final rows = await client
        .from('notices')
        .select()
        .eq('application_id', applicationId)
        .order('sent_at', ascending: false);
    return [for (final row in rows) NoticeModel.fromSnakeJson(row)];
  } catch (_) {
    return const [];
  }
});

/// Send-notice modal: destination email, prefilled from the record's
/// customer when one exists. Result is reported as a snackbar by the
/// caller; returns nothing.
Future<void> showSendNoticeDialog(
  BuildContext context,
  WidgetRef ref,
  ApplicationModel record,
) async {
  // Prefill from the customer's email when the record has one.
  var initial = '';
  final customerId = record.customerId;
  if (customerId != null) {
    final result =
        await ref.read(customersRepositoryProvider).getCustomer(customerId);
    switch (result) {
      case Success(:final value):
        initial = value?.email ?? '';
      case Failure():
        break; // prefill stays empty; the field is editable anyway
    }
  }
  if (!context.mounted) return;

  final controller = TextEditingController(text: initial);
  var busy = false;

  final destination = await showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Send notice'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: initial.isEmpty,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(labelText: 'Destination email'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: busy
                    ? null
                    : () {
                        final email = controller.text.trim();
                        if (email.isEmpty) return;
                        setDialogState(() => busy = true);
                        Navigator.of(context).pop(email);
                      },
                child: const Text('Send'),
              ),
            ],
          );
        },
      );
    },
  );
  if (destination == null || !context.mounted) return;

  String message;
  try {
    final response =
        await ref.read(supabaseClientProvider).functions.invoke(
      'send-notice',
      body: {
        'application_id': record.id,
        'channel': 'email',
        'destination': destination,
      },
    );
    final data = response.data;
    if (data is Map && data['sent'] == false) {
      message = 'Notice not sent'
          '${data['reason'] != null ? ': ${data['reason']}' : ' (no provider)'}';
    } else {
      message = 'Notice sent to $destination';
    }
  } catch (e) {
    message = 'Notice failed: $e';
  }

  ref.invalidate(noticesProvider(record.id));
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Existing notices for the record (destination, status, sent time),
/// plus the "Send notice" action.
class NoticesSection extends ConsumerWidget {
  const NoticesSection({required this.record, super.key});

  final ApplicationModel record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices =
        ref.watch(noticesProvider(record.id)).valueOrNull ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SectionHeader('Notices'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              if (notices.isEmpty)
                const ListTile(
                  dense: true,
                  title: Text('No notices sent yet.'),
                )
              else
                for (final notice in notices)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.mail_outline, size: 20),
                    title: Text(notice.destination ?? '—'),
                    subtitle: Text(
                      [
                        if (notice.deliveryStatus != null)
                          notice.deliveryStatus!,
                        if (notice.sentAt != null)
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(notice.sentAt!),
                      ].join(' · '),
                    ),
                  ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => showSendNoticeDialog(context, ref, record),
                  icon: const Icon(Icons.email),
                  label: const Text('Send notice'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
