import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/features/record/validation_client.dart';

void main() {
  test('parses a matched outcome with all fields', () {
    final outcome = ValidationOutcome.fromSnakeJson(const {
      'matched': true,
      'product_id': '9f1c2a34-5b6d-4e7f-8a9b-0c1d2e3f4a01',
      'epa_reg_no': '62719-542',
      'brand_name': 'Dimension 2EW',
      'signal_word': 'Caution',
      'match_score': 0.93,
      'rate_flag': 'over_label',
      'rate_max_value': 0.5,
      'rate_max_unit': 'oz_per_1000sqft',
      'picker_candidates': [],
    });

    expect(outcome.matched, isTrue);
    expect(outcome.productId, '9f1c2a34-5b6d-4e7f-8a9b-0c1d2e3f4a01');
    expect(outcome.epaRegNo, '62719-542');
    expect(outcome.brandName, 'Dimension 2EW');
    expect(outcome.signalWord, 'Caution');
    expect(outcome.matchScore, 0.93);
    expect(outcome.rateFlag, 'over_label');
    expect(outcome.rateMaxValue, 0.5);
    expect(outcome.rateMaxUnit, 'oz_per_1000sqft');
    expect(outcome.pickerCandidates, isEmpty);
  });

  test('parses a miss with picker candidates', () {
    final outcome = ValidationOutcome.fromSnakeJson(const {
      'matched': false,
      'picker_candidates': [
        {
          'product_id': 'p1',
          'brand_name': 'Dimension 2EW',
          'epa_reg_no': '62719-542',
          'score': 0.71,
        },
        {
          'product_id': 'p2',
          'brand_name': 'Dimension 0.15G',
          'epa_reg_no': '62719-426',
          'score': 0.55,
        },
      ],
    });

    expect(outcome.matched, isFalse);
    expect(outcome.productId, isNull);
    expect(outcome.rateFlag, isNull);
    expect(outcome.pickerCandidates, hasLength(2));
    expect(outcome.pickerCandidates.first.productId, 'p1');
    expect(outcome.pickerCandidates.first.score, 0.71);
    expect(outcome.pickerCandidates.last.brandName, 'Dimension 0.15G');
  });

  test('tolerates missing and malformed fields', () {
    final outcome = ValidationOutcome.fromSnakeJson(const {});

    expect(outcome.matched, isFalse);
    expect(outcome.brandName, isNull);
    expect(outcome.pickerCandidates, isEmpty);

    final partial = ValidationOutcome.fromSnakeJson(const {
      'matched': true,
      'match_score': 1,
      'picker_candidates': ['garbage', 42],
    });
    expect(partial.matchScore, 1.0);
    expect(partial.pickerCandidates, isEmpty);
  });
}
