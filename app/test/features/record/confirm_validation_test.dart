import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/features/record/record_draft.dart';
import 'package:spraylog/features/record/record_validation.dart';

RecordDraft _validDraft() {
  return RecordDraft(
    brandName: 'Roundup ProMax',
    rateValue: 1.5,
    rateUnit: 'oz_per_1000sqft',
    areaValue: 5000,
    areaUnit: 'sqft',
    applicationMethod: 'broadcast',
    appliedAt: DateTime.utc(2026, 6, 1, 9),
    state: 'FL',
  );
}

void main() {
  test('a complete draft has no errors', () {
    expect(RecordValidation.validateDraft(_validDraft()), isEmpty);
  });

  test('brand name is required', () {
    expect(RecordValidation.brandName(''), isNotNull);
    expect(RecordValidation.brandName('   '), isNotNull);
    expect(RecordValidation.brandName('Roundup'), isNull);

    final errors = RecordValidation.validateDraft(
      _validDraft().copyWith(brandName: ''),
    );
    expect(errors.keys, contains('brandName'));
  });

  test('rate must be present and greater than zero', () {
    expect(RecordValidation.rateValue(null), isNotNull);
    expect(RecordValidation.rateValue(0), isNotNull);
    expect(RecordValidation.rateValue(-1), isNotNull);
    expect(RecordValidation.rateValue(0.25), isNull);
  });

  test('area must be present and greater than zero', () {
    expect(RecordValidation.areaValue(null), isNotNull);
    expect(RecordValidation.areaValue(0), isNotNull);
    expect(RecordValidation.areaValue(-10), isNotNull);
    expect(RecordValidation.areaValue(1), isNull);
  });

  test('state must be a 2-letter code', () {
    expect(RecordValidation.state(''), isNotNull);
    expect(RecordValidation.state('F'), isNotNull);
    expect(RecordValidation.state('FLA'), isNotNull);
    expect(RecordValidation.state('FL'), isNull);
  });

  test('validateDraft reports every broken rule at once', () {
    final errors = RecordValidation.validateDraft(
      RecordDraft(
        brandName: '',
        rateValue: 0,
        areaValue: -1,
        appliedAt: DateTime.utc(2026, 6, 1, 9),
        state: 'FLO',
      ),
    );
    expect(
      errors.keys,
      containsAll(['brandName', 'rateValue', 'areaValue', 'state']),
    );
  });

  test('canSign gates signing on the override reason when flagged', () {
    // No flag: always signable.
    expect(
      RecordValidation.canSign(rateFlag: null, overrideReason: ''),
      isTrue,
    );

    // Flagged + empty/blank reason: blocked.
    expect(
      RecordValidation.canSign(rateFlag: 'over_label', overrideReason: ''),
      isFalse,
    );
    expect(
      RecordValidation.canSign(
        rateFlag: 'unregistered_in_state',
        overrideReason: '   ',
      ),
      isFalse,
    );

    // Flagged + reason typed: allowed.
    expect(
      RecordValidation.canSign(
        rateFlag: 'over_label',
        overrideReason: 'customer request, spot treatment only',
      ),
      isTrue,
    );
    expect(
      RecordValidation.canSign(
        rateFlag: 'unregistered_in_state',
        overrideReason: 'applied in FL where registered',
      ),
      isTrue,
    );
  });
}
