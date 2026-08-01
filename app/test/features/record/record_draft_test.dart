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

  test('photoPaths accumulate through copyWith', () {
    final draft = RecordDraft(appliedAt: DateTime.utc(2026, 6, 1, 9));
    expect(draft.photoPaths, isNull);

    final withOne = draft.copyWith(photoPaths: ['/tmp/a.jpg']);
    expect(withOne.photoPaths, ['/tmp/a.jpg']);

    final withTwo = withOne.copyWith(
      photoPaths: [...?withOne.photoPaths, '/tmp/b.jpg'],
    );
    expect(withTwo.photoPaths, ['/tmp/a.jpg', '/tmp/b.jpg']);
    // Original draft is untouched (immutable copy semantics).
    expect(draft.photoPaths, isNull);
  });

  test('product pick fields and GPS flow through copyWith', () {
    final draft = RecordDraft(appliedAt: DateTime.utc(2026, 6, 1, 9));

    final picked = draft.copyWith(
      brandName: 'Dimension 2EW',
      productId: 'product-uuid',
      epaRegNo: '62719-542',
    );
    expect(picked.productId, 'product-uuid');
    expect(picked.epaRegNo, '62719-542');

    final located = picked.copyWith(lat: 28.1, lng: -82.4);
    expect(located.lat, 28.1);
    expect(located.lng, -82.4);
    expect(located.productId, 'product-uuid');
    expect(draft.productId, isNull);
  });
}
