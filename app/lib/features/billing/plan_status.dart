import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Billing/plan state for the current company, from `companies.plan /
/// plan_status / trial_ends_at`. Recording is allowed when the
/// subscription is active, or while a trial has time left — the server
/// trigger `trg_enforce_recording_plan` is the real gate; this mirrors it
/// so the UI can degrade to read-only nicely.
class PlanStatus {
  const PlanStatus({
    required this.plan,
    required this.status,
    this.trialEndsAt,
    required this.isRecordingAllowed,
    required this.isLapsed,
    required this.daysLeftInTrial,
  });

  /// 'solo' | 'crew' | 'multi_state' (raw value kept as-is).
  final String plan;

  /// 'active' | 'trialing' | anything else (treated as ended).
  final String status;
  final DateTime? trialEndsAt;
  final bool isRecordingAllowed;
  final bool isLapsed;
  final int daysLeftInTrial;

  /// Fallback when the row can't be read (offline, missing company):
  /// allow recording — the server trigger is the authoritative gate and
  /// the confirm flow surfaces a plan_lapsed rejection nicely.
  static const unknown = PlanStatus(
    plan: '',
    status: '',
    isRecordingAllowed: true,
    isLapsed: false,
    daysLeftInTrial: 0,
  );

  factory PlanStatus.fromCompanyJson(
    Map<String, dynamic> json, {
    DateTime? now,
  }) {
    final plan = json['plan'] as String? ?? '';
    final status = json['plan_status'] as String? ?? '';
    final trialEndsAt =
        DateTime.tryParse(json['trial_ends_at'] as String? ?? '')?.toLocal();
    final reference = now ?? DateTime.now();

    final trialingWithTime = status == 'trialing' &&
        trialEndsAt != null &&
        trialEndsAt.isAfter(reference);
    final recordingAllowed = status == 'active' || trialingWithTime;

    var daysLeft = 0;
    if (status == 'trialing' && trialEndsAt != null) {
      final diff = trialEndsAt.difference(reference);
      daysLeft = diff.isNegative ? 0 : diff.inDays;
    }

    return PlanStatus(
      plan: plan,
      status: status,
      trialEndsAt: trialEndsAt,
      isRecordingAllowed: recordingAllowed,
      isLapsed: !recordingAllowed,
      daysLeftInTrial: daysLeft,
    );
  }

  /// 'solo' → 'Solo', 'multi_state' → 'Multi-state'.
  String get planDisplayName {
    return switch (plan) {
      'solo' => 'Solo',
      'crew' => 'Crew',
      'multi_state' => 'Multi-state',
      '' => 'Unknown plan',
      _ => plan,
    };
  }
}

/// Plan state for the current profile's company. Errors degrade to
/// [PlanStatus.unknown] (recording stays allowed; never locks the app on
/// a flaky network).
final planStatusProvider = FutureProvider<PlanStatus>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || profile.companyId.isEmpty) {
    return PlanStatus.unknown;
  }
  try {
    final row = await ref
        .watch(supabaseClientProvider)
        .from('companies')
        .select('plan, plan_status, trial_ends_at')
        .eq('id', profile.companyId)
        .maybeSingle();
    if (row == null) return PlanStatus.unknown;
    return PlanStatus.fromCompanyJson(row);
  } catch (_) {
    return PlanStatus.unknown;
  }
});
