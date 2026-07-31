import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

/// Launchpad: record entry point, today's activity, and sync state.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsProvider);
    final pending = ref.watch(pendingOutboxProvider);
    final online = ref.watch(connectivityProvider);

    final now = DateTime.now();
    final todayCount = (applications.valueOrNull ?? const []).where((record) {
      final applied = record.appliedAt.toLocal();
      return applied.year == now.year &&
          applied.month == now.month &&
          applied.day == now.day;
    }).length;
    final pendingCount = (pending.valueOrNull ?? const []).length;
    final isOffline = online.hasValue && online.value == false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SprayLog'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isOffline)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: const ListTile(
                leading: Icon(Icons.cloud_off),
                title: Text('Offline'),
                subtitle: Text('Records will sync when you are back online.'),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/record'),
            icon: const Icon(Icons.add),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Record application',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '$todayCount',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const Text('records today'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Chip(
                          avatar: Icon(
                            pendingCount == 0
                                ? Icons.cloud_done
                                : Icons.cloud_upload,
                            size: 18,
                          ),
                          label: Text(
                            pendingCount == 0
                                ? 'All synced'
                                : '$pendingCount pending',
                          ),
                        ),
                        const Text('sync status'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/history'),
          ),
        ],
      ),
    );
  }
}
