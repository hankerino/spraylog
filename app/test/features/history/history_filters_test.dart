import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/data/models/application.dart';
import 'package:spraylog/features/history/history_filters.dart';

ApplicationModel _record({
  required String id,
  required DateTime appliedAt,
  String applicatorId = 'user-1',
  String? signedBy,
  String? customerId,
  String brandName = 'Dimension 2EW',
}) {
  return ApplicationModel(
    id: id,
    companyId: 'company-1',
    applicatorId: applicatorId,
    customerId: customerId,
    state: 'FL',
    appliedAt: appliedAt,
    productId: 'manual',
    epaRegNo: '',
    brandName: brandName,
    rateValue: 1.5,
    rateUnit: 'oz_per_1000sqft',
    areaValue: 5000,
    areaUnit: 'sqft',
    signedAt: appliedAt,
    signedBy: signedBy ?? applicatorId,
  );
}

final _records = [
  _record(
    id: 'a',
    appliedAt: DateTime(2026, 6, 1, 9),
    applicatorId: 'mike',
    customerId: 'cust-green',
    brandName: 'Dimension 2EW',
  ),
  _record(
    id: 'b',
    appliedAt: DateTime(2026, 6, 3, 14),
    applicatorId: 'sara',
    customerId: 'cust-miller',
    brandName: 'Talstar P',
  ),
  _record(
    id: 'c',
    appliedAt: DateTime(2026, 6, 10, 8, 30),
    applicatorId: 'mike',
    customerId: 'cust-green',
    brandName: 'Tempo SC Ultra',
  ),
];

void main() {
  test('empty filters return every record', () {
    final result = applyHistoryFilters(_records, const HistoryFilters());

    expect(result.map((record) => record.id), ['a', 'b', 'c']);
    expect(const HistoryFilters().isEmpty, isTrue);
  });

  test('date range filters inclusively by calendar day', () {
    final result = applyHistoryFilters(
      _records,
      HistoryFilters(start: DateTime(2026, 6, 3), end: DateTime(2026, 6, 10)),
    );
    expect(result.map((record) => record.id), ['b', 'c']);

    // End date includes the whole day (record c is 08:30 on 6/10).
    final endOnly = applyHistoryFilters(
      _records,
      HistoryFilters(end: DateTime(2026, 6, 1)),
    );
    expect(endOnly.map((record) => record.id), ['a']);

    final startOnly = applyHistoryFilters(
      _records,
      HistoryFilters(start: DateTime(2026, 6, 4)),
    );
    expect(startOnly.map((record) => record.id), ['c']);
  });

  test('applicator filter matches id case-insensitively', () {
    final result = applyHistoryFilters(
      _records,
      const HistoryFilters(applicator: 'MIKE'),
    );
    expect(result.map((record) => record.id), ['a', 'c']);
  });

  test('customer filter matches customer id substring', () {
    final result = applyHistoryFilters(
      _records,
      const HistoryFilters(customer: 'miller'),
    );
    expect(result.map((record) => record.id), ['b']);
  });

  test('product filter matches brand name case-insensitively', () {
    final result = applyHistoryFilters(
      _records,
      const HistoryFilters(product: 'tempo'),
    );
    expect(result.map((record) => record.id), ['c']);
  });

  test('combined filters intersect', () {
    final result = applyHistoryFilters(
      _records,
      HistoryFilters(
        start: DateTime(2026, 6, 1),
        end: DateTime(2026, 6, 5),
        applicator: 'mike',
        product: 'dimension',
      ),
    );
    expect(result.map((record) => record.id), ['a']);

    final noMatch = applyHistoryFilters(
      _records,
      const HistoryFilters(applicator: 'mike', product: 'talstar'),
    );
    expect(noMatch, isEmpty);
  });
}
