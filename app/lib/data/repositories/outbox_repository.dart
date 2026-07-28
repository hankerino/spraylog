import '../../core/db/database.dart';
import '../../core/result.dart';
import '../models/outbox_item.dart';

class OutboxRepository {
  const OutboxRepository(this.database);

  final AppDatabase database;

  Future<Result<void>> save(
    OutboxItemModel item,
  ) async {
    await database.into(
      database.outboxItems,
    ).insert(
      OutboxItemsCompanion.insert(
        id: item.id,
        entity: item.entity,
        operation: item.operation,
        payload: item.payload,
        nextAttemptAt: item.nextAttemptAt,
      ),
    );

    return const Success(null);
  }

  Future<Result<List<OutboxItemModel>>> getPending() async {
    final rows = await database.select(
      database.outboxItems,
    ).get();

    final items = rows
        .map(
          (row) => OutboxItemModel(
            id: row.id,
            entity: row.entity,
            operation: row.operation,
            payload: row.payload,
            attempts: row.attempts,
            nextAttemptAt: row.nextAttemptAt,
          ),
        )
        .toList();

    return Success(items);
  }

  Future<Result<void>> delete(
    String id,
  ) async {
    await (
      database.delete(database.outboxItems)
        ..where((row) => row.id.equals(id))
    ).go();

    return const Success(null);
  }
}
