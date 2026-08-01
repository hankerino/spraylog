import 'dart:convert';

import '../../core/db/database.dart';

/// Cached product catalogue entry (reference data for the picker and the
/// product matcher). Mirrors the remote `products` table; JSON keys are
/// snake_case at the boundary.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.epaRegNo,
    required this.brandName,
    this.brandAliases = const [],
    this.signalWord,
    this.formulation,
    this.reiHours,
    this.restrictedUse = false,
    required this.updatedAt,
  });

  final String id;
  final String epaRegNo;
  final String brandName;
  final List<String> brandAliases;
  final String? signalWord;
  final String? formulation;
  final double? reiHours;
  final bool restrictedUse;
  final DateTime updatedAt;

  factory ProductModel.fromDrift(Product row) {
    return ProductModel(
      id: row.id,
      epaRegNo: row.epaRegNo,
      brandName: row.brandName,
      brandAliases: _decodeAliases(row.brandAliases),
      signalWord: row.signalWord,
      formulation: row.formulation,
      reiHours: row.reiHours,
      restrictedUse: row.restrictedUse,
      updatedAt: row.updatedAt,
    );
  }

  /// Remote row / seed asset shape: snake_case keys, `brand_aliases` as a
  /// JSON list, timestamps as ISO8601.
  factory ProductModel.fromSnakeJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      epaRegNo: json['epa_reg_no'] as String? ?? '',
      brandName: json['brand_name'] as String? ?? '',
      brandAliases:
          (json['brand_aliases'] as List?)?.whereType<String>().toList() ??
              const [],
      signalWord: json['signal_word'] as String?,
      formulation: json['formulation'] as String?,
      reiHours: (json['rei_hours'] as num?)?.toDouble(),
      restrictedUse: json['restricted_use'] as bool? ?? false,
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '')?.toUtc() ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  static List<String> _decodeAliases(String encoded) {
    try {
      final decoded = jsonDecode(encoded);
      return decoded is List
          ? decoded.whereType<String>().toList()
          : const [];
    } catch (_) {
      return const [];
    }
  }
}
