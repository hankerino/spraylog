import '../../core/db/database.dart';
import '../../core/result.dart';
import '../models/outbox_item.dart';

class OutboxRepository {
  const OutboxRepository(this.database);

  final AppDatabase database;

  Future<Result<void>> save(
    OutboxItemModel item,
  ) async {
    return const Success(null);
  }

  Future<Result<List<OutboxItemModel>>> getPending() async {
    return const Success([]);
  }

  Future<Result<void>> delete(
    String id,
  ) async {
    return const Success(null);
  }
}
