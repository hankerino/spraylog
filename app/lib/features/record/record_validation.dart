import 'record_draft.dart';

/// Pure validation rules for the confirm screen. Returns field-keyed error
/// messages; an empty map means the draft is ready to sign.
class RecordValidation {
  const RecordValidation._();

  static String? brandName(String value) {
    return value.trim().isEmpty ? 'Product brand name is required' : null;
  }

  static String? rateValue(double? value) {
    if (value == null) return 'Rate is required';
    return value <= 0 ? 'Rate must be greater than 0' : null;
  }

  static String? areaValue(double? value) {
    if (value == null) return 'Area is required';
    return value <= 0 ? 'Area must be greater than 0' : null;
  }

  static String? state(String value) {
    return value.trim().length != 2
        ? 'State must be a 2-letter code (e.g. FL)'
        : null;
  }

  /// Validates [draft]; keys are stable field identifiers used by the
  /// confirm screen to render inline errors.
  static Map<String, String> validateDraft(RecordDraft draft) {
    return {
      if (brandName(draft.brandName) case final error?)
        'brandName': error,
      if (rateValue(draft.rateValue) case final error?) 'rateValue': error,
      if (areaValue(draft.areaValue) case final error?) 'areaValue': error,
      if (state(draft.state) case final error?) 'state': error,
    };
  }
}
