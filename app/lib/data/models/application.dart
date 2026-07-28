class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.companyId,
    required this.applicatorId,
    required this.state,
    required this.appliedAt,
    required this.productId,
    required this.epaRegNo,
    required this.brandName,
    required this.rateValue,
    required this.rateUnit,
    required this.areaValue,
    required this.areaUnit,
    this.signedAt,
    this.signedBy,
    this.recordHash,
    this.prevHash,
  });

  final String id;
  final String companyId;
  final String applicatorId;

  final String state;
  final DateTime appliedAt;

  final String productId;
  final String epaRegNo;
  final String brandName;

  final double rateValue;
  final String rateUnit;

  final double areaValue;
  final String areaUnit;

  final DateTime? signedAt;
  final String? signedBy;

  final String? recordHash;
  final String? prevHash;
}
