import '../../data/models/application.dart';

/// Filter state for the history list. All dimensions are optional; an
/// empty [HistoryFilters] matches everything. Dates are inclusive local
/// calendar days (start-of-day .. end-of-day).
class HistoryFilters {
  const HistoryFilters({
    this.start,
    this.end,
    this.applicator = '',
    this.customer = '',
    this.product = '',
  });

  final DateTime? start;
  final DateTime? end;
  final String applicator;
  final String customer;
  final String product;

  bool get isEmpty =>
      start == null &&
      end == null &&
      applicator.trim().isEmpty &&
      customer.trim().isEmpty &&
      product.trim().isEmpty;

  HistoryFilters copyWith({
    DateTime? start,
    DateTime? end,
    String? applicator,
    String? customer,
    String? product,
    bool clearDates = false,
  }) {
    return HistoryFilters(
      start: clearDates ? null : start ?? this.start,
      end: clearDates ? null : end ?? this.end,
      applicator: applicator ?? this.applicator,
      customer: customer ?? this.customer,
      product: product ?? this.product,
    );
  }
}

/// Pure client-side filtering over local records (works fully offline).
List<ApplicationModel> applyHistoryFilters(
  List<ApplicationModel> records,
  HistoryFilters filters,
) {
  final applicatorNeedle = filters.applicator.trim().toLowerCase();
  final customerNeedle = filters.customer.trim().toLowerCase();
  final productNeedle = filters.product.trim().toLowerCase();

  final start = filters.start;
  final startBound = start == null
      ? null
      : DateTime(start.year, start.month, start.day);
  final end = filters.end;
  // Inclusive of the whole end day.
  final endBound =
      end == null ? null : DateTime(end.year, end.month, end.day + 1);

  return [
    for (final record in records)
      if ((startBound == null ||
              !record.appliedAt.toLocal().isBefore(startBound)) &&
          (endBound == null || record.appliedAt.toLocal().isBefore(endBound)) &&
          (applicatorNeedle.isEmpty ||
              record.applicatorId.toLowerCase().contains(applicatorNeedle) ||
              (record.signedBy?.toLowerCase().contains(applicatorNeedle) ??
                  false)) &&
          (customerNeedle.isEmpty ||
              (record.customerId?.toLowerCase().contains(customerNeedle) ??
                  false)) &&
          (productNeedle.isEmpty ||
              record.brandName.toLowerCase().contains(productNeedle)))
        record,
  ];
}
