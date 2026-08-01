import 'package:flutter/material.dart';

import '../../core/theme/spraylog_theme.dart';

/// Colored sync-state chip: synced = sky, pending = amber, unsigned =
/// error tint. Used by the history list and the record detail screen.
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({
    required this.signed,
    required this.pending,
    super.key,
  });

  final bool signed;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch ((signed, pending)) {
      (false, _) => ('unsigned', scheme.errorContainer, scheme.onErrorContainer),
      (true, true) => ('pending', SpraylogTheme.brandAmber, SpraylogTheme.brandInk),
      (true, false) => ('synced', SpraylogTheme.brandSky, SpraylogTheme.brandInk),
    };
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 12),
      ),
      backgroundColor: background,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
