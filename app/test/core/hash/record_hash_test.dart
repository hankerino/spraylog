import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/core/hash/record_hash.dart';
import 'package:spraylog/data/models/application.dart';

ApplicationModel _unsigned({
  required String id,
  required DateTime signedAt,
  String brandName = 'Roundup ProMax',
}) {
  return ApplicationModel(
    id: id,
    companyId: 'company-1',
    applicatorId: 'user-1',
    state: 'FL',
    appliedAt: DateTime.utc(2026, 6, 1, 9),
    productId: 'manual',
    epaRegNo: '524-579',
    brandName: brandName,
    rateValue: 1.5,
    rateUnit: 'oz_per_1000sqft',
    areaValue: 5000,
    areaUnit: 'sqft',
    targetPest: 'crabgrass',
    applicationMethod: 'broadcast',
    signedAt: signedAt,
    signedBy: 'user-1',
  );
}

ApplicationModel _sign(ApplicationModel record, String prevHash) {
  final linked = record.copyWith(prevHash: prevHash);
  final hash = computeRecordHash(canonicalPayload(linked), prevHash);
  return linked.copyWith(recordHash: hash);
}

void main() {
  test('hash is deterministic for the same input', () {
    final record = _unsigned(
      id: 'a',
      signedAt: DateTime.utc(2026, 6, 1, 10),
    );

    final first = computeRecordHash(canonicalPayload(record), genesisPrevHash);
    final second = computeRecordHash(canonicalPayload(record), genesisPrevHash);

    expect(first, second);
    expect(first, hasLength(64));

    // A separately-built identical record hashes identically.
    final twin = _unsigned(
      id: 'a',
      signedAt: DateTime.utc(2026, 6, 1, 10),
    );
    expect(
      computeRecordHash(canonicalPayload(twin), genesisPrevHash),
      first,
    );
  });

  test('record N links to record N-1 hash and the chain verifies', () {
    final first = _sign(
      _unsigned(id: 'a', signedAt: DateTime.utc(2026, 6, 1, 10)),
      genesisPrevHash,
    );
    final second = _sign(
      _unsigned(id: 'b', signedAt: DateTime.utc(2026, 6, 2, 10)),
      first.recordHash!,
    );

    expect(first.prevHash, genesisPrevHash);
    expect(second.prevHash, first.recordHash);

    // Pass deliberately reversed to prove ordering is normalized.
    expect(verifyChain([second, first]), isTrue);
  });

  test('tampering with a signed field breaks verifyChain', () {
    final first = _sign(
      _unsigned(id: 'a', signedAt: DateTime.utc(2026, 6, 1, 10)),
      genesisPrevHash,
    );
    final second = _sign(
      _unsigned(id: 'b', signedAt: DateTime.utc(2026, 6, 2, 10)),
      first.recordHash!,
    );

    final tampered = first.copyWith(brandName: 'Cheap Knockoff');
    expect(verifyChain([second, tampered]), isFalse);

    // A forged prevHash linkage is also detected.
    final forged = second.copyWith(prevHash: genesisPrevHash);
    expect(verifyChain([first, forged]), isFalse);
  });
}
