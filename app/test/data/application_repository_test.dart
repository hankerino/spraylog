import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/core/db/database.dart';
import 'package:spraylog/core/result.dart';
import 'package:spraylog/data/models/application.dart';
import 'package:spraylog/data/repositories/application_repository.dart';

ApplicationModel _sample({
  required String id,
  String companyId = 'company-1',
  DateTime? appliedAt,
  DateTime? signedAt,
  String? recordHash,
  String? prevHash,
}) {
  return ApplicationModel(
    id: id,
    companyId: companyId,
    applicatorId: 'user-1',
    customerId: 'customer-1',
    state: 'FL',
    appliedAt: appliedAt ?? DateTime.utc(2026, 6, 1, 9),
    productId: 'manual',
    epaRegNo: '524-579',
    brandName: 'Roundup ProMax',
    rateValue: 1.5,
    rateUnit: 'oz_per_1000sqft',
    totalAmountValue: 32,
    totalAmountUnit: 'oz',
    areaValue: 5000,
    areaUnit: 'sqft',
    targetPest: 'crabgrass',
    applicationMethod: 'broadcast',
    signedAt: signedAt,
    signedBy: signedAt == null ? null : 'user-1',
    recordHash: recordHash,
    prevHash: prevHash,
  );
}

void main() {
  late AppDatabase db;
  late ApplicationRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ApplicationRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('save + getById roundtrips the full record', () async {
    final record = _sample(
      id: 'a',
      signedAt: DateTime.utc(2026, 6, 1, 10),
      recordHash: 'hash-a',
      prevHash: '0' * 64,
    );

    final saved = await repository.save(record);
    expect(saved, isA<Success<void>>());

    final loaded = await repository.getById('a');
    expect(loaded, isA<Success<ApplicationModel?>>());
    final value = (loaded as Success<ApplicationModel?>).value;
    expect(value, isNotNull);
    expect(value!.id, record.id);
    expect(value.companyId, record.companyId);
    expect(value.customerId, record.customerId);
    expect(value.brandName, record.brandName);
    expect(value.rateValue, record.rateValue);
    expect(value.totalAmountValue, record.totalAmountValue);
    expect(value.totalAmountUnit, record.totalAmountUnit);
    expect(value.targetPest, record.targetPest);
    expect(value.applicationMethod, record.applicationMethod);
    // Drift reads DateTimes back in local time; compare the instant.
    expect(
      value.signedAt!.isAtSameMomentAs(record.signedAt!),
      isTrue,
    );
    expect(value.recordHash, record.recordHash);
    expect(value.prevHash, record.prevHash);
  });

  test('getById returns null for a missing id', () async {
    final loaded = await repository.getById('missing');
    expect((loaded as Success<ApplicationModel?>).value, isNull);
  });

  test('getAll returns newest first and filters by company', () async {
    await repository.save(
      _sample(id: 'old', appliedAt: DateTime.utc(2026, 6, 1, 9)),
    );
    await repository.save(
      _sample(id: 'new', appliedAt: DateTime.utc(2026, 6, 3, 9)),
    );
    await repository.save(
      _sample(
        id: 'other-company',
        companyId: 'company-2',
        appliedAt: DateTime.utc(2026, 6, 2, 9),
      ),
    );

    final all = await repository.getAll();
    final allValues = (all as Success<List<ApplicationModel>>).value;
    expect(allValues.map((record) => record.id), ['new', 'other-company', 'old']);

    final filtered = await repository.getAll(companyId: 'company-1');
    final filteredValues = (filtered as Success<List<ApplicationModel>>).value;
    expect(filteredValues.map((record) => record.id), ['new', 'old']);
  });

  test('latestSignedHash picks the most recently signed record', () async {
    expect(
      (await repository.latestSignedHash('company-1'))
          as Success<String?>,
      isA<Success<String?>>().having(
        (success) => success.value,
        'value',
        isNull,
      ),
    );

    await repository.save(
      _sample(
        id: 'unsigned',
        appliedAt: DateTime.utc(2026, 6, 3, 9),
      ),
    );
    await repository.save(
      _sample(
        id: 'first',
        appliedAt: DateTime.utc(2026, 6, 1, 9),
        signedAt: DateTime.utc(2026, 6, 1, 10),
        recordHash: 'hash-1',
      ),
    );
    await repository.save(
      _sample(
        id: 'second',
        appliedAt: DateTime.utc(2026, 6, 2, 9),
        signedAt: DateTime.utc(2026, 6, 2, 10),
        recordHash: 'hash-2',
      ),
    );
    await repository.save(
      _sample(
        id: 'other-company',
        companyId: 'company-2',
        signedAt: DateTime.utc(2026, 6, 4, 10),
        recordHash: 'hash-other',
      ),
    );

    final latest = await repository.latestSignedHash('company-1');
    expect((latest as Success<String?>).value, 'hash-2');
  });
}
