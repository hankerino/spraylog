import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers.dart';
import 'record_draft.dart';

/// A product candidate returned by the validate-application function when
/// the spoken/typed product could not be resolved confidently.
class PickerCandidate {
  const PickerCandidate({
    required this.productId,
    required this.brandName,
    required this.epaRegNo,
    required this.score,
  });

  final String productId;
  final String brandName;
  final String epaRegNo;
  final double score;

  factory PickerCandidate.fromSnakeJson(Map<String, dynamic> json) {
    return PickerCandidate(
      productId: json['product_id'] as String? ?? '',
      brandName: json['brand_name'] as String? ?? '',
      epaRegNo: json['epa_reg_no'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Authoritative result of the validate-application edge function (spec §3).
/// JSON keys are snake_case at the boundary.
class ValidationOutcome {
  const ValidationOutcome({
    required this.matched,
    this.productId,
    this.epaRegNo,
    this.brandName,
    this.signalWord,
    this.matchScore,
    this.rateFlag,
    this.rateMaxValue,
    this.rateMaxUnit,
    this.pickerCandidates = const [],
  });

  final bool matched;
  final String? productId;
  final String? epaRegNo;
  final String? brandName;
  final String? signalWord;
  final double? matchScore;

  /// 'over_label' | 'unregistered_in_state' | null.
  final String? rateFlag;
  final double? rateMaxValue;
  final String? rateMaxUnit;

  final List<PickerCandidate> pickerCandidates;

  factory ValidationOutcome.fromSnakeJson(Map<String, dynamic> json) {
    return ValidationOutcome(
      matched: json['matched'] as bool? ?? false,
      productId: json['product_id'] as String?,
      epaRegNo: json['epa_reg_no'] as String?,
      brandName: json['brand_name'] as String?,
      signalWord: json['signal_word'] as String?,
      matchScore: (json['match_score'] as num?)?.toDouble(),
      rateFlag: json['rate_flag'] as String?,
      rateMaxValue: (json['rate_max_value'] as num?)?.toDouble(),
      rateMaxUnit: json['rate_max_unit'] as String?,
      pickerCandidates: [
        for (final candidate in json['picker_candidates'] as List? ?? const [])
          if (candidate is Map<String, dynamic>)
            PickerCandidate.fromSnakeJson(candidate),
      ],
    );
  }
}

/// Client seam for the validate-application edge function. Callers treat
/// any throw as "validation unavailable" and stay on the manual path.
abstract class ValidationClient {
  Future<ValidationOutcome> validate(RecordDraft draft);
}

class RemoteValidationClient implements ValidationClient {
  const RemoteValidationClient(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<ValidationOutcome> validate(RecordDraft draft) async {
    final response = await _supabase.functions.invoke(
      'validate-application',
      body: {
        'spoken_product': draft.brandName.trim(),
        'state': draft.state.trim().toUpperCase(),
        if (draft.rateValue != null) 'rate_value': draft.rateValue,
        'rate_unit': draft.rateUnit,
      },
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('unexpected validate-application response');
    }
    return ValidationOutcome.fromSnakeJson(data);
  }
}

final validationClientProvider = Provider<ValidationClient>(
  (ref) => RemoteValidationClient(ref.watch(supabaseClientProvider)),
);
