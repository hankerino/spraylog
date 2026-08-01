import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/errors.dart';
import '../../core/result.dart';
import '../models/product.dart';

class ProductsRepository {
  const ProductsRepository(this.database);

  final AppDatabase database;

  Future<Result<void>> upsertAll(
    List<ProductModel> products,
  ) async {
    try {
      await database.batch((batch) {
        for (final product in products) {
          batch.insert(
            database.products,
            ProductsCompanion.insert(
              id: product.id,
              epaRegNo: product.epaRegNo,
              brandName: product.brandName,
              brandAliases: jsonEncode(product.brandAliases),
              signalWord: Value(product.signalWord),
              formulation: Value(product.formulation),
              reiHours: Value(product.reiHours),
              restrictedUse: Value(product.restrictedUse),
              updatedAt: product.updatedAt,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      return const Success(null);
    } catch (error) {
      return Failure(DatabaseError('failed to upsert products: $error'));
    }
  }

  Future<Result<List<ProductModel>>> getAll() async {
    try {
      final rows = await (database.select(database.products)
            ..orderBy([(row) => OrderingTerm.asc(row.brandName)]))
          .get();

      return Success(rows.map(ProductModel.fromDrift).toList());
    } catch (error) {
      return Failure(DatabaseError('failed to load products: $error'));
    }
  }

  /// Case-insensitive contains on brand name and JSON-encoded aliases.
  Future<Result<List<ProductModel>>> search(
    String query,
  ) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return getAll();

    try {
      final rows = await (database.select(database.products)
            ..where(
              (row) =>
                  row.brandName.lower().like('%$trimmed%') |
                  row.brandAliases.lower().like('%$trimmed%'),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.brandName)]))
          .get();

      return Success(rows.map(ProductModel.fromDrift).toList());
    } catch (error) {
      return Failure(DatabaseError('failed to search products: $error'));
    }
  }

  Future<Result<ProductModel?>> getById(
    String id,
  ) async {
    try {
      final row = await (database.select(database.products)
            ..where((rows) => rows.id.equals(id)))
          .getSingleOrNull();

      return Success(row == null ? null : ProductModel.fromDrift(row));
    } catch (error) {
      return Failure(DatabaseError('failed to load product: $error'));
    }
  }
}
