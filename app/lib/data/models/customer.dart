/// Customer record from the remote `customers` table (RLS per company).
/// Read/written directly against Supabase for now — offline cache is a
/// later concern.
class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.notifyVia = 'none',
    this.smsCarrier,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;

  /// sms | email | none
  final String notifyVia;

  /// Email-to-SMS gateway carrier key (see [smsCarrierLabels]); nullable.
  final String? smsCarrier;

  factory CustomerModel.fromSnakeJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notifyVia: json['notify_via'] as String? ?? 'none',
      smsCarrier: json['sms_carrier'] as String?,
    );
  }
}

/// Email-to-SMS gateway carriers accepted by send-notice: value → label.
const smsCarrierLabels = {
  'verizon': 'Verizon',
  'att': 'AT&T',
  'tmobile': 'T-Mobile',
  'sprint': 'Sprint',
  'uscellular': 'US Cellular',
  'cricket': 'Cricket',
  'boost': 'Boost Mobile',
  'metro': 'Metro by T-Mobile',
};
