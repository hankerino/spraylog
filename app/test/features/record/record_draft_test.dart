import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/features/record/record_draft.dart';

void main() {
  test('RecordDraft carries a voice transcript', () {
    final draft = RecordDraft(
      brandName: 'Roundup ProMax',
      appliedAt: DateTime.utc(2026, 6, 1, 9),
      transcript: 'sprayed roundup at one point five ounces per thousand',
    );

    expect(
      draft.transcript,
      'sprayed roundup at one point five ounces per thousand',
    );
  });

  test('transcript survives copyWith edits through the confirm flow', () {
    final captured = RecordDraft(
      appliedAt: DateTime.utc(2026, 6, 1, 9),
      transcript: 'spot treated dandelions with speedzone',
    );

    // Mimic the confirm screen's inline edits + extraction prefill.
    final edited = captured
        .copyWith(brandName: 'Speedzone', rateValue: 1.1)
        .copyWith(state: 'FL');

    expect(edited.transcript, captured.transcript);
    expect(edited.brandName, 'Speedzone');
    expect(edited.rateValue, 1.1);
    expect(edited.state, 'FL');
  });

  test('transcript defaults to null for manual entry', () {
    final draft = RecordDraft(appliedAt: DateTime.utc(2026, 6, 1, 9));

    expect(draft.transcript, isNull);
  });
}
