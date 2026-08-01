import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors.dart';
import '../../core/providers.dart';
import '../../core/result.dart';
import '../models/customer.dart';
import '../models/site.dart';

/// Customers & sites against the remote tables directly (drift-free for
/// now — an offline cache is a later concern, so every call needs
/// connectivity; failures surface as [NetworkError]).
class CustomersRepository {
  const CustomersRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<Result<List<CustomerModel>>> list({
    String? query,
  }) async {
    try {
      var request = _supabase.from('customers').select();
      final trimmed = query?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        request = request.ilike('name', '%$trimmed%');
      }
      final rows = await request.order('name');
      return Success([
        for (final row in rows) CustomerModel.fromSnakeJson(row),
      ]);
    } catch (error) {
      return Failure(NetworkError('failed to load customers: $error'));
    }
  }

  Future<Result<CustomerModel?>> getCustomer(
    String id,
  ) async {
    try {
      final row =
          await _supabase.from('customers').select().eq('id', id).maybeSingle();
      return Success(row == null ? null : CustomerModel.fromSnakeJson(row));
    } catch (error) {
      return Failure(NetworkError('failed to load customer: $error'));
    }
  }

  Future<Result<CustomerModel?>> addCustomer({
    required String companyId,
    required String name,
    String? phone,
    String? email,
    String notifyVia = 'none',
  }) async {
    try {
      final row = await _supabase
          .from('customers')
          .insert({
            'company_id': companyId,
            'name': name.trim(),
            if (phone != null && phone.trim().isNotEmpty)
              'phone': phone.trim(),
            if (email != null && email.trim().isNotEmpty)
              'email': email.trim(),
            'notify_via': notifyVia,
          })
          .select()
          .single();
      return Success(CustomerModel.fromSnakeJson(row));
    } catch (error) {
      return Failure(NetworkError('failed to add customer: $error'));
    }
  }

  Future<Result<List<SiteModel>>> listSites(
    String customerId,
  ) async {
    try {
      final rows = await _supabase
          .from('sites')
          .select()
          .eq('customer_id', customerId)
          .order('label');
      return Success([
        for (final row in rows) SiteModel.fromSnakeJson(row),
      ]);
    } catch (error) {
      return Failure(NetworkError('failed to load sites: $error'));
    }
  }

  Future<Result<SiteModel?>> addSite({
    required String companyId,
    required String customerId,
    required String label,
    String? address,
    String? state,
    double? areaValue,
    String? areaUnit,
  }) async {
    try {
      final row = await _supabase
          .from('sites')
          .insert({
            'company_id': companyId,
            'customer_id': customerId,
            'label': label.trim(),
            if (address != null && address.trim().isNotEmpty)
              'address': address.trim(),
            if (state != null && state.trim().isNotEmpty)
              'state': state.trim().toUpperCase(),
            if (areaValue != null) 'area_value': areaValue,
            if (areaUnit != null) 'area_unit': areaUnit,
          })
          .select()
          .single();
      return Success(SiteModel.fromSnakeJson(row));
    } catch (error) {
      return Failure(NetworkError('failed to add site: $error'));
    }
  }
}

final customersRepositoryProvider = Provider<CustomersRepository>(
  (ref) => CustomersRepository(ref.watch(supabaseClientProvider)),
);
