import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/features/billing/plan_status.dart';

void main() {
  final now = DateTime(2026, 7, 15, 12);

  test('active plan allows recording and is not lapsed', () {
    final status = PlanStatus.fromCompanyJson(
      const {'plan': 'crew', 'plan_status': 'active'},
      now: now,
    );

    expect(status.plan, 'crew');
    expect(status.planDisplayName, 'Crew');
    expect(status.isRecordingAllowed, isTrue);
    expect(status.isLapsed, isFalse);
    expect(status.daysLeftInTrial, 0);
  });

  test('trialing with time left allows recording and counts days', () {
    final status = PlanStatus.fromCompanyJson(
      {
        'plan': 'solo',
        'plan_status': 'trialing',
        'trial_ends_at': '2026-07-25T12:00:00Z',
      },
      now: now,
    );

    expect(status.isRecordingAllowed, isTrue);
    expect(status.isLapsed, isFalse);
    expect(status.daysLeftInTrial, 10);
  });

  test('trialing past the trial end is lapsed', () {
    final status = PlanStatus.fromCompanyJson(
      {
        'plan': 'solo',
        'plan_status': 'trialing',
        'trial_ends_at': '2026-07-10T12:00:00Z',
      },
      now: now,
    );

    expect(status.isRecordingAllowed, isFalse);
    expect(status.isLapsed, isTrue);
    expect(status.daysLeftInTrial, 0);
  });

  test('trialing with a missing trial date is lapsed (strict formula)', () {
    final status = PlanStatus.fromCompanyJson(
      const {'plan': 'solo', 'plan_status': 'trialing'},
      now: now,
    );

    expect(status.trialEndsAt, isNull);
    expect(status.isRecordingAllowed, isFalse);
    expect(status.isLapsed, isTrue);
  });

  test('non-active non-trialing status is lapsed', () {
    for (final value in ['past_due', 'canceled', 'lapsed']) {
      final status = PlanStatus.fromCompanyJson(
        {'plan': 'multi_state', 'plan_status': value},
        now: now,
      );
      expect(status.isRecordingAllowed, isFalse, reason: value);
      expect(status.isLapsed, isTrue, reason: value);
      expect(status.planDisplayName, 'Multi-state', reason: value);
    }
  });

  test('empty row maps to not-allowed; unknown constant stays allowed', () {
    final status = PlanStatus.fromCompanyJson(const {}, now: now);
    expect(status.isRecordingAllowed, isFalse);
    expect(status.isLapsed, isTrue);
    expect(status.planDisplayName, 'Unknown plan');

    // The provider fallback never locks the app on read failures.
    expect(PlanStatus.unknown.isRecordingAllowed, isTrue);
    expect(PlanStatus.unknown.isLapsed, isFalse);
  });
}
