/// Mutable-in-spirit draft passed from the entry form to the confirm screen.
/// Numeric fields stay null until the user enters a parseable value.
class RecordDraft {
  const RecordDraft({
    this.brandName = '',
    this.rateValue,
    this.rateUnit = 'oz_per_1000sqft',
    this.areaValue,
    this.areaUnit = 'sqft',
    this.targetPest = '',
    this.applicationMethod = 'broadcast',
    required this.appliedAt,
    this.state = '',
  });

  final String brandName;
  final double? rateValue;
  final String rateUnit;
  final double? areaValue;
  final String areaUnit;
  final String targetPest;
  final String applicationMethod;
  final DateTime appliedAt;
  final String state;

  static const rateUnits = [
    'oz_per_1000sqft',
    'lb_per_acre',
    'pct_solution',
  ];

  static const areaUnits = [
    'sqft',
    'acre',
    'linear_ft',
  ];

  static const applicationMethods = [
    'broadcast',
    'spot',
    'perimeter',
    'drench',
    'granular',
  ];

  RecordDraft copyWith({
    String? brandName,
    double? rateValue,
    String? rateUnit,
    double? areaValue,
    String? areaUnit,
    String? targetPest,
    String? applicationMethod,
    DateTime? appliedAt,
    String? state,
  }) {
    return RecordDraft(
      brandName: brandName ?? this.brandName,
      rateValue: rateValue ?? this.rateValue,
      rateUnit: rateUnit ?? this.rateUnit,
      areaValue: areaValue ?? this.areaValue,
      areaUnit: areaUnit ?? this.areaUnit,
      targetPest: targetPest ?? this.targetPest,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      appliedAt: appliedAt ?? this.appliedAt,
      state: state ?? this.state,
    );
  }
}
