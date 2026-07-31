import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/spraylog_theme.dart';

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  SpraylogTheme.brandTurf,
                  SpraylogTheme.brandTurfDark,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.spa, size: 36, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  'SprayLog',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Voice-first application records',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          if (isOffline)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: const ListTile(
                  leading: Icon(Icons.cloud_off),
                  title: Text('Offline'),
                  subtitle:
                      Text('Records will sync when you are back online.'),
                ),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/record'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'Record application',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.today,
                  value: '$todayCount',
                  label: 'records today',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: pendingCount == 0
                      ? Icons.check_circle
                      : Icons.cloud_upload,
                  value: pendingCount == 0
                      ? 'All synced'
                      : '$pendingCount pending',
                  label: 'sync status',
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: SpraylogTheme.brandTurf),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
