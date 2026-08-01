import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/product.dart';
import '../../data/repositories/products_repository.dart';
import '../providers.dart';
import '../result.dart';

/// Pulls the remote `products` catalogue into the local cache. An empty
/// remote table is fine (seed lands later): when remote returns zero rows
/// and the local cache is empty, the bundled seed asset is loaded instead.
/// Offline/errors degrade to the same asset fallback — never throws.
class CatalogueSync {
  const CatalogueSync(this._supabase, this._products);

  final SupabaseClient _supabase;
  final ProductsRepository _products;

  Future<Result<void>> sync() async {
    try {
      final rows = await _supabase.from('products').select();
      final remote = [
        for (final row in rows)
          ProductModel.fromSnakeJson(row),
      ];
      if (remote.isNotEmpty) {
        return _products.upsertAll(remote);
      }
      // Empty remote: fall through to the seed fallback.
      await _seedIfEmpty();
      return const Success(null);
    } catch (_) {
      // Offline or remote failure: best-effort seed, never an error.
      await _seedIfEmpty();
      return const Success(null);
    }
  }

  Future<void> _seedIfEmpty() async {
    final local = await _products.getAll();
    if (local is! Success<List<ProductModel>> || local.value.isNotEmpty) {
      return;
    }
    try {
      final raw = await rootBundle.loadString('assets/seed_products.json');
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final seed = [
        for (final row in decoded)
          ProductModel.fromSnakeJson(row as Map<String, dynamic>),
      ];
      if (seed.isNotEmpty) await _products.upsertAll(seed);
    } catch (_) {
      // Missing/invalid seed asset: leave the catalogue empty; the
      // picker falls back to free text.
    }
  }
}

/// Local catalogue contents; refreshed after each sync run.
final productsCatalogueProvider = FutureProvider<List<ProductModel>>(
  (ref) async {
    final result = await ref.watch(productsRepositoryProvider).getAll();
    return switch (result) {
      Success(:final value) => value,
      Failure() => const [],
    };
  },
);

/// Runs once at startup (watched from App.build); refreshes the catalogue
/// provider when done.
final catalogueSyncProvider = FutureProvider<void>((ref) async {
  final sync = CatalogueSync(
    ref.watch(supabaseClientProvider),
    ref.watch(productsRepositoryProvider),
  );
  await sync.sync();
  ref.invalidate(productsCatalogueProvider);
});
