import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers.dart';

/// Candidate fields extracted from a voice transcript by the extraction
/// edge function. Every field except [confidence] is nullable — the model
/// only returns what it could parse; [unparsedRemainder] keeps whatever it
/// could not map. JSON keys are snake_case, matching the edge function
/// contract.
class ExtractionResult {
  const ExtractionResult({
    required this.confidence,
    this.spokenProduct,
    this.rateValue,
    this.rateUnit,
    this.areaValue,
    this.areaUnit,
    this.targetPest,
    this.applicationMethod,
    this.siteHint,
    this.tempF,
    this.windMph,
    this.windDirection,
    this.unparsedRemainder,
  });

  final String? spokenProduct;
  final double? rateValue;
  final String? rateUnit;
  final double? areaValue;
  final String? areaUnit;
  final String? targetPest;
  final String? applicationMethod;
  final String? siteHint;
  final double? tempF;
  final double? windMph;
  final String? windDirection;
  final double confidence;
  final String? unparsedRemainder;

  /// Below this confidence the product needs a manual pick (M4 picker).
  static const confidenceThreshold = 0.75;

  bool get isLowConfidence => confidence < confidenceThreshold;

  factory ExtractionResult.fromJson(Map<String, dynamic> json) {
    return ExtractionResult(
      confidence: (json['confidence'] as num).toDouble(),
      spokenProduct: json['spoken_product'] as String?,
      rateValue: (json['rate_value'] as num?)?.toDouble(),
      rateUnit: json['rate_unit'] as String?,
      areaValue: (json['area_value'] as num?)?.toDouble(),
      areaUnit: json['area_unit'] as String?,
      targetPest: json['target_pest'] as String?,
      applicationMethod: json['application_method'] as String?,
      siteHint: json['site_hint'] as String?,
      tempF: (json['temp_f'] as num?)?.toDouble(),
      windMph: (json['wind_mph'] as num?)?.toDouble(),
      windDirection: json['wind_direction'] as String?,
      unparsedRemainder: json['unparsed_remainder'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'spoken_product': spokenProduct,
      'rate_value': rateValue,
      'rate_unit': rateUnit,
      'area_value': areaValue,
      'area_unit': areaUnit,
      'target_pest': targetPest,
      'application_method': applicationMethod,
      'site_hint': siteHint,
      'temp_f': tempF,
      'wind_mph': windMph,
      'wind_direction': windDirection,
      'unparsed_remainder': unparsedRemainder,
    };
  }
}

/// Client seam for the extraction edge function (built separately).
/// Implementations must not throw across the UI boundary unchecked —
/// callers treat any error as "extraction unavailable" and stay manual.
abstract class ExtractionClient {
  Future<ExtractionResult> extract(String transcript);
}

/// Placeholder until the edge function ships: always unsupported.
class StubExtractionClient implements ExtractionClient {
  const StubExtractionClient();

  @override
  Future<ExtractionResult> extract(String transcript) {
    throw UnsupportedError('extraction edge function not available yet');
  }
}

/// Live client against the deployed `extract-application` edge function.
/// supabase_flutter attaches the current session JWT automatically.
class RemoteExtractionClient implements ExtractionClient {
  const RemoteExtractionClient(this._client);

  final SupabaseClient _client;

  @override
  Future<ExtractionResult> extract(String transcript) async {
    final response = await _client.functions.invoke(
      'extract-application',
      body: {'transcript': transcript},
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('extraction failed (${response.status})');
    }
    final error = data['error'];
    if (error != null) {
      throw StateError('extraction failed: $error');
    }
    return ExtractionResult.fromJson(data);
  }
}

final extractionClientProvider = Provider<ExtractionClient>(
  (ref) => RemoteExtractionClient(ref.watch(supabaseClientProvider)),
);
