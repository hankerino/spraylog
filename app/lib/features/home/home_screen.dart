import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/spraylog_theme.dart';
import '../../core/widgets/brand_mark.dart';
import '../billing/plan_status.dart';

/// Launchpad: record entry point, today's activity, and sync state.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsProvider);
    final pending = ref.watch(pendingOutboxProvider);
    final online = ref.watch(connectivityProvider);
    final plan = ref.watch(planStatusProvider).valueOrNull;

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
        actions: [
          IconButton(
            tooltip: 'Toggle dark mode',
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final current = ref.read(themeModeProvider);
              final isDark =
                  current == ThemeMode.dark ||
                  (current == ThemeMode.system &&
                      MediaQuery.of(context).platformBrightness ==
                          Brightness.dark);
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
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
                  SpraylogTheme.brandSky,
                  SpraylogTheme.brandSkyDeep,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandMark(size: 44),
                    const SizedBox(width: 12),
                    Text(
                      'SprayLog',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
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
          if (plan?.isLapsed == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: SpraylogTheme.brandAmber,
                child: const ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Subscription ended — records are read-only.'),
                  subtitle: Text(
                    'History and export stay available forever.',
                  ),
                ),
              ),
            ),
          Opacity(
            opacity: plan?.isLapsed == true ? 0.5 : 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    SpraylogTheme.brandSky,
                    SpraylogTheme.brandSkyDeep,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: plan?.isLapsed == true
                      ? null
                      : () => context.push('/record'),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Record application',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
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
          if (plan != null && !plan.isLapsed && plan.status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: Icon(
                    plan.status == 'trialing'
                        ? Icons.hourglass_top
                        : Icons.workspace_premium,
                    size: 18,
                    color: plan.status == 'trialing' &&
                            plan.daysLeftInTrial <= 3
                        ? SpraylogTheme.brandInk
                        : Colors.white,
                  ),
                  label: Text(
                    plan.status == 'trialing'
                        ? 'Trial: ${plan.daysLeftInTrial} days left'
                        : plan.planDisplayName,
                    style: TextStyle(
                      color: plan.status == 'trialing' &&
                              plan.daysLeftInTrial <= 3
                          ? SpraylogTheme.brandInk
                          : Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  backgroundColor: plan.status == 'trialing' &&
                          plan.daysLeftInTrial <= 3
                      ? SpraylogTheme.brandAmber
                      : SpraylogTheme.brandNavy,
                  side: BorderSide.none,
                ),
              ),
            ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/history'),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Customers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/customers'),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('State export'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/export'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
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
        color: SpraylogTheme.brandSkySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: SpraylogTheme.brandNavy),
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
