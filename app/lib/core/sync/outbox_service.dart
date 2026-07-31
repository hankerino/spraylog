import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/outbox_item.dart';
import '../../data/repositories/outbox_repository.dart';
import '../db/database.dart';
import '../result.dart';

/// Drains the outbox queue to Supabase with exponential backoff.
///
/// Records never wait on the network: every write is persisted locally first
/// and enqueued here. Delivery is attempted on enqueue, on app resume, and on
/// connectivity regain (wired by the caller).
class OutboxService {
  OutboxService(this._db, this._outbox, this._supabase);

  final AppDatabase _db;
  final OutboxRepository _outbox;
  final SupabaseClient _supabase;

  static const _baseDelay = Duration(seconds: 5);
  static const _maxDelay = Duration(minutes: 15);

  /// Delay before attempt [attempts] (0-based): base × 2^n, capped at 15 min.
  static Duration backoffFor(int attempts) {
    final seconds = _baseDelay.inSeconds << attempts.clamp(0, 10);
    return Duration(seconds: seconds) > _maxDelay
        ? _maxDelay
        : Duration(seconds: seconds);
  }

  bool _draining = false;

  Future<Result<void>> enqueue({
    required String id,
    required String entity,
    required String operation,
    required String payload,
  }) async {
    final save = await _outbox.save(
      OutboxItemModel(
        id: id,
        entity: entity,
        operation: operation,
        payload: payload,
        attempts: 0,
        nextAttemptAt: DateTime.now().toUtc(),
      ),
    );
    if (save is Failure<void>) return save;

    // Fire-and-forget drain; failures reschedule inside the queue.
    unawaited(processQueue());
    return const Success(null);
  }

  Future<Result<void>> processQueue() async {
    if (_draining) return const Success(null);
    _draining = true;
    try {
      final pending = await _outbox.getPending();
      if (pending is Failure<List<OutboxItemModel>>) {
        return Failure(pending.error);
      }
      final items = (pending as Success<List<OutboxItemModel>>).value;
      // ignore: avoid_print
      print('[OutboxService] drain: ${items.length} pending');
      final now = DateTime.now().toUtc();
      for (final item in items) {
        if (item.nextAttemptAt.isAfter(now)) continue;
        try {
          await _deliver(item).timeout(const Duration(seconds: 20));
          await _outbox.delete(item.id);
          // ignore: avoid_print
          print('[OutboxService] delivered ${item.id}');
        } catch (e) {
          // Surface the real delivery error in debug builds — otherwise
          // outbox stalls are invisible (seen during M2 device testing).
          // ignore: avoid_print
          print('[OutboxService] delivery failed for ${item.id}: $e');
          await _reschedule(item);
        }
      }
      return const Success(null);
    } finally {
      _draining = false;
    }
  }

  Future<void> _deliver(OutboxItemModel item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    // Legacy payloads queued before the sentinel fix still carry
    // product_id: 'manual' — the remote column is a uuid FK.
    if (payload['product_id'] == 'manual') payload['product_id'] = null;
    if (item.entity == 'application' && item.operation == 'insert') {
      await _supabase.from('applications').insert(payload);
      return;
    }
    throw StateError('unknown outbox op ${item.entity}/${item.operation}');
  }

  Future<void> _reschedule(OutboxItemModel item) async {
    final attempts = item.attempts + 1;
    final next = DateTime.now().toUtc().add(backoffFor(item.attempts));
    await (_db.update(_db.outboxItems)
          ..where((row) => row.id.equals(item.id)))
        .write(
      OutboxItemsCompanion(
        attempts: Value(attempts),
        nextAttemptAt: Value(next),
      ),
    );
  }
}
