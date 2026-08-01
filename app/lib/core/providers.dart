import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/auth_state.dart' as app_auth;
import '../../data/models/application.dart';
import '../../data/models/outbox_item.dart';
import '../../data/models/profile.dart';
import 'db/database.dart';
import 'result.dart';
import 'sync/outbox_service.dart';
import '../../data/repositories/application_repository.dart';
import '../../data/repositories/outbox_repository.dart';
import '../../data/repositories/products_repository.dart';

/// Supabase client singleton (initialized in main.dart before runApp).
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Local drift database. Closed when the provider is disposed.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final applicationRepositoryProvider = Provider<ApplicationRepository>(
  (ref) => ApplicationRepository(ref.watch(appDatabaseProvider)),
);

final outboxRepositoryProvider = Provider<OutboxRepository>(
  (ref) => OutboxRepository(ref.watch(appDatabaseProvider)),
);

final outboxServiceProvider = Provider<OutboxService>(
  (ref) => OutboxService(
    ref.watch(appDatabaseProvider),
    ref.watch(outboxRepositoryProvider),
    ref.watch(supabaseClientProvider),
  ),
);

final productsRepositoryProvider = Provider<ProductsRepository>(
  (ref) => ProductsRepository(ref.watch(appDatabaseProvider)),
);

/// Live auth state driven by the Supabase session stream.
final authStateProvider = StreamProvider<app_auth.AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) {
    final userId = event.session?.user.id;
    if (userId == null) {
      return const app_auth.AuthState(status: app_auth.AuthStatus.unauthenticated);
    }
    return app_auth.AuthState(
      status: app_auth.AuthStatus.authenticated,
      userId: userId,
    );
  });
});

/// Profile row for the signed-in user, cached for the session. Used to
/// resolve the company new records belong to.
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final userId = ref.watch(authStateProvider).valueOrNull?.userId;
  if (userId == null) return null;

  final client = ref.watch(supabaseClientProvider);
  final row = await client
      .from('profiles')
      .select()
      .eq('id', userId)
      .maybeSingle();
  if (row == null) return null;

  return Profile(
    id: row['id'] as String? ?? userId,
    companyId: row['company_id'] as String? ?? '',
    fullName: row['full_name'] as String? ?? '',
    role: row['role'] as String? ?? '',
  );
});

/// Pending (undelivered) outbox items; drives sync indicators.
final pendingOutboxProvider = FutureProvider<List<OutboxItemModel>>(
  (ref) async {
    final result = await ref.watch(outboxRepositoryProvider).getPending();
    return switch (result) {
      Success(:final value) => value,
      Failure() => const [],
    };
  },
);

/// All locally stored applications, newest first.
final applicationsProvider = FutureProvider<List<ApplicationModel>>(
  (ref) async {
    final result = await ref.watch(applicationRepositoryProvider).getAll();
    return switch (result) {
      Success(:final value) => value,
      Failure() => const [],
    };
  },
);

/// Single application by id, or null when not found locally.
final applicationByIdProvider =
    FutureProvider.family<ApplicationModel?, String>((ref, id) async {
  final result = await ref.watch(applicationRepositoryProvider).getById(id);
  return switch (result) {
    Success(:final value) => value,
    Failure() => null,
  };
});

/// True while any network transport is available.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
        (results) => results.any(
          (result) => result != ConnectivityResult.none,
        ),
      );
});

/// Kicks the outbox whenever connectivity comes back (spec §5: sync on
/// reconnect), plus one drain at startup. Watch this provider once from
/// the app root.
final outboxReconnectSyncProvider = Provider<void>((ref) {
  // Initial drain on app start (covers items queued while offline at
  // a previous run).
  ref.read(outboxServiceProvider).processQueue();

  ref.listen<AsyncValue<bool>>(
    connectivityProvider,
    (previous, next) {
      final wasOffline = previous?.valueOrNull == false;
      final isOnline = next.valueOrNull == true;
      if (wasOffline && isOnline) {
        ref.read(outboxServiceProvider).processQueue();
      }
    },
    fireImmediately: false,
  );
});

/// Light/dark override. Defaults to following the system setting.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
