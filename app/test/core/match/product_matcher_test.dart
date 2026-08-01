import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/core/match/product_matcher.dart';
import 'package:spraylog/data/models/product.dart';

ProductModel _product({
  required String id,
  required String brandName,
  List<String> aliases = const [],
}) {
  return ProductModel(
    id: id,
    epaRegNo: '000-000',
    brandName: brandName,
    brandAliases: aliases,
    updatedAt: DateTime.utc(2026),
  );
}

final _catalogue = [
  _product(
    id: 'p1',
    brandName: 'Dimension 2EW',
    aliases: ['dimension', 'dimension two e w', 'dithiopyr'],
  ),
  _product(
    id: 'p2',
    brandName: 'Talstar P',
    aliases: ['talstar', 'bifenthrin'],
  ),
  _product(
    id: 'p3',
    brandName: 'Tempo SC Ultra',
    aliases: ['tempo', 'tempo s c', 'cyfluthrin'],
  ),
  _product(
    id: 'p4',
    brandName: 'Tempo Xtra',
    aliases: const [],
  ),
];

void main() {
  test('exact brand name matches at 1.0', () {
    final result = ProductMatcher.match('Dimension 2EW', _catalogue);

    expect(result.best?.product.id, 'p1');
    expect(result.topScore, 1.0);
  });

  test('spoken form "dimension two e w" resolves via alias', () {
    final result = ProductMatcher.match('dimension two e w', _catalogue);

    expect(result.best?.product.id, 'p1');
    expect(result.topScore, 1.0);
  });

  test('spoken letter groups match: "tempo s c ultra"', () {
    final result = ProductMatcher.match('tempo s c ultra', _catalogue);

    expect(result.best?.product.id, 'p3');
  });

  test('spoken numbers normalize: "dimension 2 e w"', () {
    final result = ProductMatcher.match('dimension 2 e w', _catalogue);

    expect(result.best?.product.id, 'p1');
  });

  test('below-threshold query forces no match', () {
    final result = ProductMatcher.match('glyphosate roundup', _catalogue);

    expect(result.best, isNull);
    expect(result.topScore, lessThan(matchThreshold));
  });

  test('candidates are sorted by score descending', () {
    final result = ProductMatcher.match('tempo', _catalogue);

    expect(result.candidates.length, greaterThanOrEqualTo(2));
    for (var i = 1; i < result.candidates.length; i++) {
      expect(
        result.candidates[i - 1].score,
        greaterThanOrEqualTo(result.candidates[i].score),
      );
    }
    expect(result.candidates.first.product.id, 'p3');
    // Both Tempo products surface above the 0.5 candidate floor.
    expect(
      result.candidates.map((match) => match.product.id),
      containsAll(['p3', 'p4']),
    );
  });

  test('empty query or empty catalogue returns nothing', () {
    expect(ProductMatcher.match('', _catalogue).candidates, isEmpty);
    expect(ProductMatcher.match('tempo', const []).best, isNull);
  });

  test('normalize handles punctuation, casing, and speak-spell forms', () {
    expect(ProductMatcher.normalize('  Talstar,  P! '), 'talstar p');
    expect(ProductMatcher.normalize('Tempo SC Ultra'), 'tempo sc ultra');
    expect(ProductMatcher.normalize('two'), '2');
    expect(ProductMatcher.normalize('e w'), 'ew');
  });
}
