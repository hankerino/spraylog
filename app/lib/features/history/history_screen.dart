import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import 'sync_status_chip.dart';

/// Local application records, newest first, with per-record sync state.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsProvider);
    final pending = ref.watch(pendingOutboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(applicationsProvider);
          ref.invalidate(pendingOutboxProvider);
        },
        child: applications.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load records: $error'),
              ),
            ],
          ),
          data: (records) {
            if (records.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No records yet. Record your first application.'),
                    ),
                  ),
                ],
              );
            }
            final pendingIds = {
              for (final item in pending.valueOrNull ?? const []) item.id,
            };
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final isPending = pendingIds.contains(record.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(record.brandName),
                    subtitle: Text(
                      '${DateFormat('yyyy-MM-dd HH:mm').format(record.appliedAt.toLocal())} · ${record.state}',
                    ),
                    trailing: SyncStatusChip(
                      signed: record.signedAt != null,
                      pending: isPending,
                    ),
                    onTap: () => context.push('/history/${record.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
