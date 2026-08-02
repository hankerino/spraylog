import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/result.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/application.dart';
import '../../data/models/customer.dart';
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

/// Send-notice modal: Email or SMS (free email-to-SMS gateway). Destination
/// and carrier prefill from the record's customer when available. Result
/// is reported as a snackbar; returns nothing.
Future<void> showSendNoticeDialog(
  BuildContext context,
  WidgetRef ref,
  ApplicationModel record,
) async {
  // Prefill from the customer when the record has one.
  var prefillEmail = '';
  var prefillPhone = '';
  String? prefillCarrier;
  final customerId = record.customerId;
  if (customerId != null) {
    final result =
        await ref.read(customersRepositoryProvider).getCustomer(customerId);
    switch (result) {
      case Success(:final value):
        prefillEmail = value?.email ?? '';
        prefillPhone = value?.phone ?? '';
        prefillCarrier = value?.smsCarrier;
      case Failure():
        break; // prefill stays empty; fields are editable anyway
    }
  }
  if (!context.mounted) return;

  final request = await showDialog<_NoticeRequest>(
    context: context,
    builder: (context) => _SendNoticeDialog(
      prefillEmail: prefillEmail,
      prefillPhone: prefillPhone,
      prefillCarrier: prefillCarrier,
    ),
  );
  if (request == null || !context.mounted) return;

  String message;
  try {
    final response =
        await ref.read(supabaseClientProvider).functions.invoke(
      'send-notice',
      body: {
        'application_id': record.id,
        'channel': request.channel,
        'destination': request.destination,
        if (request.carrier != null) 'carrier': request.carrier,
      },
    );
    final data = response.data;
    final status = data is Map ? data['status'] as String? : null;
    message = switch (status) {
      'sent' => 'Notice sent to ${request.destination}',
      'skipped_no_provider' =>
        'Notice saved — provider not configured yet',
      'failed' => 'Notice failed',
      _ => data is Map && data['sent'] == false
          ? 'Notice not sent'
              '${data['reason'] != null ? ': ${data['reason']}' : ''}'
          : 'Notice sent to ${request.destination}',
    };
  } catch (e) {
    message = 'Notice failed: $e';
  }

  ref.invalidate(noticesProvider(record.id));
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NoticeRequest {
  const _NoticeRequest({
    required this.channel,
    required this.destination,
    this.carrier,
  });

  final String channel;
  final String destination;
  final String? carrier;
}

class _SendNoticeDialog extends StatefulWidget {
  const _SendNoticeDialog({
    required this.prefillEmail,
    required this.prefillPhone,
    this.prefillCarrier,
  });

  final String prefillEmail;
  final String prefillPhone;
  final String? prefillCarrier;

  @override
  State<_SendNoticeDialog> createState() => _SendNoticeDialogState();
}

class _SendNoticeDialogState extends State<_SendNoticeDialog> {
  late final TextEditingController _destination;
  late String _channel;
  String? _carrier;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Default to email, unless only SMS details are available.
    _channel = widget.prefillEmail.isNotEmpty || widget.prefillPhone.isEmpty
        ? 'email'
        : 'sms';
    _destination = TextEditingController(
      text: _channel == 'email' ? widget.prefillEmail : widget.prefillPhone,
    );
    _carrier = widget.prefillCarrier;
  }

  @override
  void dispose() {
    _destination.dispose();
    super.dispose();
  }

  void _switchChannel(String channel) {
    if (channel == _channel) return;
    setState(() {
      _channel = channel;
      _error = null;
      _destination.text =
          channel == 'email' ? widget.prefillEmail : widget.prefillPhone;
    });
  }

  void _send() {
    final destination = _destination.text.trim();
    if (_channel == 'email') {
      if (destination.isEmpty) {
        setState(() => _error = 'Destination email is required');
        return;
      }
      Navigator.of(context).pop(
        _NoticeRequest(channel: 'email', destination: destination),
      );
      return;
    }
    final digits = destination.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      setState(() => _error = 'Enter a 10-digit US phone number');
      return;
    }
    final carrier = _carrier;
    if (carrier == null) {
      setState(() => _error = 'Carrier is required for SMS');
      return;
    }
    Navigator.of(context).pop(
      _NoticeRequest(
        channel: 'sms',
        destination: digits,
        carrier: carrier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSms = _channel == 'sms';
    return AlertDialog(
      title: const Text('Send notice'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'email',
                label: Text('Email'),
                icon: Icon(Icons.email),
              ),
              ButtonSegment(
                value: 'sms',
                label: Text('SMS'),
                icon: Icon(Icons.sms),
              ),
            ],
            selected: {_channel},
            onSelectionChanged: (selection) =>
                _switchChannel(selection.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _destination,
            autofocus: _destination.text.isEmpty,
            keyboardType: isSms
                ? TextInputType.phone
                : TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText:
                  isSms ? 'Phone (10-digit US)' : 'Destination email',
            ),
          ),
          if (isSms) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _carrier,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Mobile carrier',
                hintText: 'Needed for free SMS delivery',
              ),
              items: [
                for (final entry in smsCarrierLabels.entries)
                  DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
              ],
              onChanged: (value) => setState(() => _carrier = value),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _send,
          child: const Text('Send'),
        ),
      ],
    );
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
                    leading: Icon(
                      notice.channel == 'sms' ? Icons.sms : Icons.mail_outline,
                      size: 20,
                    ),
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
