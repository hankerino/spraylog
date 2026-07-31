import '../../core/db/database.dart';

/// Local representation of a pesticide application record.
///
/// Mirrors the drift `Applications` table / remote `applications` record.
/// Signed records are immutable and chained via [prevHash] → [recordHash].
class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.companyId,
    required this.applicatorId,
    this.customerId,
    this.siteId,
    required this.state,
    required this.appliedAt,
    required this.productId,
    required this.epaRegNo,
    required this.brandName,
    required this.rateValue,
    required this.rateUnit,
    this.totalAmountValue,
    this.totalAmountUnit,
    required this.areaValue,
    required this.areaUnit,
    this.targetPest,
    this.applicationMethod,
    this.lat,
    this.lng,
    this.tempF,
    this.windMph,
    this.windDirection,
    this.weatherSource,
    this.transcript,
    this.extractionModel,
    this.extractionConfidence,
    this.rateFlag,
    this.overrideReason,
    this.signedAt,
    this.signedBy,
    this.recordHash,
    this.prevHash,
  });

  final String id;
  final String companyId;
  final String applicatorId;
  final String? customerId;
  final String? siteId;

  final String state;
  final DateTime appliedAt;

  final String productId;
  final String epaRegNo;
  final String brandName;

  final double rateValue;
  final String rateUnit;

  final double? totalAmountValue;
  final String? totalAmountUnit;

  final double areaValue;
  final String areaUnit;

  final String? targetPest;
  final String? applicationMethod;

  final double? lat;
  final double? lng;
  final double? tempF;
  final double? windMph;
  final String? windDirection;
  final String? weatherSource;

  final String? transcript;
  final String? extractionModel;
  final double? extractionConfidence;
  final String? rateFlag;
  final String? overrideReason;

  final DateTime? signedAt;
  final String? signedBy;

  final String? recordHash;
  final String? prevHash;

  factory ApplicationModel.fromDrift(Application row) {
    return ApplicationModel(
      id: row.id,
      companyId: row.companyId,
      applicatorId: row.applicatorId,
      customerId: row.customerId,
      siteId: row.siteId,
      state: row.state,
      appliedAt: row.appliedAt,
      productId: row.productId,
      epaRegNo: row.epaRegNo,
      brandName: row.brandName,
      rateValue: row.rateValue,
      rateUnit: row.rateUnit,
      totalAmountValue: row.totalAmountValue,
      totalAmountUnit: row.totalAmountUnit,
      areaValue: row.areaValue,
      areaUnit: row.areaUnit,
      targetPest: row.targetPest,
      applicationMethod: row.applicationMethod,
      lat: row.lat,
      lng: row.lng,
      tempF: row.tempF,
      windMph: row.windMph,
      windDirection: row.windDirection,
      weatherSource: row.weatherSource,
      transcript: row.transcript,
      extractionModel: row.extractionModel,
      extractionConfidence: row.extractionConfidence,
      rateFlag: row.rateFlag,
      overrideReason: row.overrideReason,
      signedAt: row.signedAt,
      signedBy: row.signedBy,
      recordHash: row.recordHash,
      prevHash: row.prevHash,
    );
  }

  /// Payload for the remote `applications` table / outbox queue.
  /// Keys are snake_case matching the remote columns; timestamps are UTC.
  Map<String, dynamic> toSnakeJson() {
    return {
      'id': id,
      'company_id': companyId,
      'applicator_id': applicatorId,
      'customer_id': customerId,
      'site_id': siteId,
      'state': state,
      'applied_at': appliedAt.toUtc().toIso8601String(),
      // Manual entries carry the local 'manual' sentinel — the remote
      // product_id column is a uuid FK, so map it to null (M4 catalogue
      // resolves real product ids).
      'product_id': productId == 'manual' ? null : productId,
      'epa_reg_no': epaRegNo,
      'brand_name': brandName,
      'rate_value': rateValue,
      'rate_unit': rateUnit,
      'total_amount_value': totalAmountValue,
      'total_amount_unit': totalAmountUnit,
      'area_value': areaValue,
      'area_unit': areaUnit,
      'target_pest': targetPest,
      'application_method': applicationMethod,
      'lat': lat,
      'lng': lng,
      'temp_f': tempF,
      'wind_mph': windMph,
      'wind_direction': windDirection,
      'weather_source': weatherSource,
      'transcript': transcript,
      'extraction_model': extractionModel,
      'extraction_confidence': extractionConfidence,
      'rate_flag': rateFlag,
      'override_reason': overrideReason,
      'signed_at': signedAt?.toUtc().toIso8601String(),
      'signed_by': signedBy,
      'prev_hash': prevHash,
      'record_hash': recordHash,
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? companyId,
    String? applicatorId,
    String? customerId,
    String? siteId,
    String? state,
    DateTime? appliedAt,
    String? productId,
    String? epaRegNo,
    String? brandName,
    double? rateValue,
    String? rateUnit,
    double? totalAmountValue,
    String? totalAmountUnit,
    double? areaValue,
    String? areaUnit,
    String? targetPest,
    String? applicationMethod,
    double? lat,
    double? lng,
    double? tempF,
    double? windMph,
    String? windDirection,
    String? weatherSource,
    String? transcript,
    String? extractionModel,
    double? extractionConfidence,
    String? rateFlag,
    String? overrideReason,
    DateTime? signedAt,
    String? signedBy,
    String? recordHash,
    String? prevHash,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      applicatorId: applicatorId ?? this.applicatorId,
      customerId: customerId ?? this.customerId,
      siteId: siteId ?? this.siteId,
      state: state ?? this.state,
      appliedAt: appliedAt ?? this.appliedAt,
      productId: productId ?? this.productId,
      epaRegNo: epaRegNo ?? this.epaRegNo,
      brandName: brandName ?? this.brandName,
      rateValue: rateValue ?? this.rateValue,
      rateUnit: rateUnit ?? this.rateUnit,
      totalAmountValue: totalAmountValue ?? this.totalAmountValue,
      totalAmountUnit: totalAmountUnit ?? this.totalAmountUnit,
      areaValue: areaValue ?? this.areaValue,
      areaUnit: areaUnit ?? this.areaUnit,
      targetPest: targetPest ?? this.targetPest,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tempF: tempF ?? this.tempF,
      windMph: windMph ?? this.windMph,
      windDirection: windDirection ?? this.windDirection,
      weatherSource: weatherSource ?? this.weatherSource,
      transcript: transcript ?? this.transcript,
      extractionModel: extractionModel ?? this.extractionModel,
      extractionConfidence:
          extractionConfidence ?? this.extractionConfidence,
      rateFlag: rateFlag ?? this.rateFlag,
      overrideReason: overrideReason ?? this.overrideReason,
      signedAt: signedAt ?? this.signedAt,
      signedBy: signedBy ?? this.signedBy,
      recordHash: recordHash ?? this.recordHash,
      prevHash: prevHash ?? this.prevHash,
    );
  }
}
