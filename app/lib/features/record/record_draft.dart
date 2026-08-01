/// Mutable-in-spirit draft passed from the entry form to the confirm screen.
/// Numeric fields stay null until the user enters a parseable value.
/// [transcript] carries a voice-captured transcript for extraction.
/// [productId]/[epaRegNo]/[signalWord] are set when a product is resolved
/// (picker or validate-application); [lat]/[lng] are GPS-autofilled on the
/// confirm screen and drive the weather autofill; [photoPaths] holds local
/// camera captures (upload lands in a later milestone).
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
    this.transcript,
    this.productId,
    this.epaRegNo,
    this.signalWord,
    this.lat,
    this.lng,
    this.tempF,
    this.windMph,
    this.windDirection,
    this.weatherSource,
    this.photoPaths,
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
  final String? transcript;
  final String? productId;
  final String? epaRegNo;
  final String? signalWord;
  final double? lat;
  final double? lng;
  final double? tempF;
  final double? windMph;
  final String? windDirection;
  final String? weatherSource;
  final List<String>? photoPaths;

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
    String? transcript,
    String? productId,
    String? epaRegNo,
    String? signalWord,
    double? lat,
    double? lng,
    double? tempF,
    double? windMph,
    String? windDirection,
    String? weatherSource,
    List<String>? photoPaths,
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
      transcript: transcript ?? this.transcript,
      productId: productId ?? this.productId,
      epaRegNo: epaRegNo ?? this.epaRegNo,
      signalWord: signalWord ?? this.signalWord,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tempF: tempF ?? this.tempF,
      windMph: windMph ?? this.windMph,
      windDirection: windDirection ?? this.windDirection,
      weatherSource: weatherSource ?? this.weatherSource,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }
}
