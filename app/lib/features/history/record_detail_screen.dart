import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/models/application.dart';
import '../../data/models/outbox_item.dart';

/// Read-only detail of a single record, including hash-chain fields.
class RecordDetailScreen extends ConsumerWidget {
  const RecordDetailScreen({required this.id, super.key});

  final String id;

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value == null || value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }

  Widget _hashRow(String label, String? value) {
    final display = value == null
        ? '—'
        : value.length > 20
            ? '${value.substring(0, 10)}…${value.substring(value.length - 6)}'
            : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              display,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final application = ref.watch(applicationByIdProvider(id));
    final pending = ref.watch(pendingOutboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record detail'),
      ),
      body: application.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load: $error')),
        data: (record) {
          if (record == null) {
            return const Center(child: Text('Record not found.'));
          }
          return _detail(context, record, pending.valueOrNull ?? const []);
        },
      ),
    );
  }

  Widget _detail(
    BuildContext context,
    ApplicationModel record,
    List<OutboxItemModel> pendingItems,
  ) {
    final pendingIds = {for (final item in pendingItems) item.id};
    final synced = !pendingIds.contains(record.id);
    final syncLabel = record.signedAt == null
        ? 'unsigned'
        : synced
            ? 'synced'
            : 'pending sync';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _row('Brand name', record.brandName),
        _row('Applied at',
            DateFormat('yyyy-MM-dd HH:mm').format(record.appliedAt.toLocal())),
        _row('State', record.state),
        _row('Rate', '${record.rateValue} ${record.rateUnit}'),
        _row('Area', '${record.areaValue} ${record.areaUnit}'),
        _row('Target pest', record.targetPest),
        _row('Method', record.applicationMethod),
        _row('Product id', record.productId),
        _row('EPA reg no', record.epaRegNo),
        _row('Total amount', record.totalAmountValue == null
            ? null
            : '${record.totalAmountValue} ${record.totalAmountUnit ?? ''}'),
        _row('Customer', record.customerId),
        _row('Site', record.siteId),
        _row('GPS', record.lat == null
            ? null
            : '${record.lat}, ${record.lng}'),
        _row('Temp (F)', record.tempF?.toString()),
        _row('Wind (mph)', record.windMph?.toString()),
        _row('Wind direction', record.windDirection),
        _row('Weather source', record.weatherSource),
        _row('Rate flag', record.rateFlag),
        _row('Override reason', record.overrideReason),
        _row('Signed at', record.signedAt == null
            ? null
            : DateFormat('yyyy-MM-dd HH:mm')
                .format(record.signedAt!.toLocal())),
        _row('Signed by', record.signedBy),
        _row('Sync state', syncLabel),
        const Divider(height: 24),
        _hashRow('record_hash', record.recordHash),
        _hashRow('prev_hash', record.prevHash),
      ],
    );
  }
}
