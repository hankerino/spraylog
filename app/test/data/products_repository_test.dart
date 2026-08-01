import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/core/db/database.dart';
import 'package:spraylog/core/result.dart';
import 'package:spraylog/data/models/product.dart';
import 'package:spraylog/data/repositories/products_repository.dart';

ProductModel _product({
  required String id,
  required String brandName,
  String epaRegNo = '000-000',
  List<String> aliases = const [],
}) {
  return ProductModel(
    id: id,
    epaRegNo: epaRegNo,
    brandName: brandName,
    brandAliases: aliases,
    signalWord: 'Caution',
    formulation: 'liquid',
    reiHours: 12,
    updatedAt: DateTime.utc(2026),
  );
}

void main() {
  late AppDatabase db;
  late ProductsRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ProductsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('upsertAll + getAll roundtrips products with aliases', () async {
    final saved = await repository.upsertAll([
      _product(
        id: 'p1',
        brandName: 'Dimension 2EW',
        epaRegNo: '62719-542',
        aliases: ['dimension', 'dimension two e w'],
      ),
      _product(id: 'p2', brandName: 'Talstar P'),
    ]);
    expect(saved, isA<Success<void>>());

    final all = await repository.getAll();
    final products = (all as Success<List<ProductModel>>).value;
    expect(products, hasLength(2));
    // Ordered by brand name.
    expect(products.first.brandName, 'Dimension 2EW');
    expect(products.first.epaRegNo, '62719-542');
    expect(products.first.brandAliases, ['dimension', 'dimension two e w']);
    expect(products.first.signalWord, 'Caution');
    expect(products.first.reiHours, 12);
    expect(products.first.restrictedUse, isFalse);
  });

  test('upsertAll replaces an existing id', () async {
    await repository.upsertAll([_product(id: 'p1', brandName: 'Old Name')]);
    await repository.upsertAll([_product(id: 'p1', brandName: 'New Name')]);

    final all = await repository.getAll();
    final products = (all as Success<List<ProductModel>>).value;
    expect(products, hasLength(1));
    expect(products.single.brandName, 'New Name');
  });

  test('search matches brand name case-insensitively', () async {
    await repository.upsertAll([
      _product(id: 'p1', brandName: 'Dimension 2EW'),
      _product(id: 'p2', brandName: 'Talstar P'),
    ]);

    final result = await repository.search('dimension');
    final products = (result as Success<List<ProductModel>>).value;
    expect(products.map((product) => product.id), ['p1']);

    final upper = await repository.search('TALSTAR');
    expect(
      (upper as Success<List<ProductModel>>).value.map((p) => p.id),
      ['p2'],
    );
  });

  test('search matches inside the JSON-encoded aliases', () async {
    await repository.upsertAll([
      _product(
        id: 'p1',
        brandName: 'Dimension 2EW',
        aliases: ['dithiopyr'],
      ),
      _product(id: 'p2', brandName: 'Talstar P'),
    ]);

    final result = await repository.search('dithiopyr');
    expect(
      (result as Success<List<ProductModel>>).value.map((p) => p.id),
      ['p1'],
    );
  });

  test('empty search returns everything; getById roundtrips', () async {
    await repository.upsertAll([
      _product(id: 'p1', brandName: 'Dimension 2EW'),
      _product(id: 'p2', brandName: 'Talstar P'),
    ]);

    final all = await repository.search('   ');
    expect((all as Success<List<ProductModel>>).value, hasLength(2));

    final byId = await repository.getById('p2');
    expect((byId as Success<ProductModel?>).value?.brandName, 'Talstar P');

    final missing = await repository.getById('nope');
    expect((missing as Success<ProductModel?>).value, isNull);
  });
}
