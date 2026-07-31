import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../data/models/application.dart';

/// Prev-hash for the first signed record of a company (64 zeros).
const String genesisPrevHash =
    '0000000000000000000000000000000000000000000000000000000000000000';

/// Builds the canonical payload for [record]: every signed field of the
/// record, excluding `record_hash` (the value being computed) and
/// `prev_hash` (supplied separately to [computeRecordHash]). Timestamps are
/// UTC ISO8601 via [ApplicationModel.toSnakeJson].
Map<String, dynamic> canonicalPayload(ApplicationModel record) {
  final json = record.toSnakeJson()
    ..remove('record_hash')
    ..remove('prev_hash');
  return json;
}

/// Serializes [payload] deterministically: object keys sorted recursively.
String canonicalJson(Map<String, dynamic> payload) {
  return jsonEncode(_sortKeys(payload));
}

/// sha256 hex of `canonicalJson(canonicalPayload) + prevHash`.
String computeRecordHash(
  Map<String, dynamic> canonicalPayload,
  String prevHash,
) {
  final input = canonicalJson(canonicalPayload) + prevHash;
  return sha256.convert(utf8.encode(input)).toString();
}

/// Verifies a company's chain of signed [records]: the first links to
/// [genesisPrevHash], each subsequent record links to the previous record's
/// hash, and every stored hash recomputes correctly. Chain order is
/// `signedAt` ascending (tie-broken by id), matching the insertion order
/// used when signing.
bool verifyChain(List<ApplicationModel> records) {
  if (records.isEmpty) return true;

  final sorted = [...records]..sort((a, b) {
      final aSigned = a.signedAt;
      final bSigned = b.signedAt;
      if (aSigned == null || bSigned == null) return 0;
      final bySigned = aSigned.compareTo(bSigned);
      return bySigned != 0 ? bySigned : a.id.compareTo(b.id);
    });

  var prev = genesisPrevHash;
  for (final record in sorted) {
    if (record.signedAt == null) return false;
    if (record.prevHash != prev) return false;
    final hash = record.recordHash;
    if (hash == null) return false;
    if (computeRecordHash(canonicalPayload(record), prev) != hash) {
      return false;
    }
    prev = hash;
  }
  return true;
}

Object? _sortKeys(Object? value) {
  if (value is Map<String, dynamic>) {
    final keys = value.keys.toList()..sort();
    return {
      for (final key in keys) key: _sortKeys(value[key]),
    };
  }
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return {
      for (final key in keys) key: _sortKeys(value[key]),
    };
  }
  if (value is List) {
    return value.map(_sortKeys).toList();
  }
  return value;
}
