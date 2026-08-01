/// Site (service location) belonging to a customer, from the remote
/// `sites` table. Direct Supabase access for now — offline cache is a
/// later concern.
class SiteModel {
  const SiteModel({
    required this.id,
    required this.customerId,
    required this.label,
    this.address,
    this.state,
    this.areaValue,
    this.areaUnit,
  });

  final String id;
  final String customerId;
  final String label;
  final String? address;
  final String? state;
  final double? areaValue;
  final String? areaUnit;

  factory SiteModel.fromSnakeJson(Map<String, dynamic> json) {
    return SiteModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      address: json['address'] as String?,
      state: json['state'] as String?,
      areaValue: (json['area_value'] as num?)?.toDouble(),
      areaUnit: json['area_unit'] as String?,
    );
  }
}
