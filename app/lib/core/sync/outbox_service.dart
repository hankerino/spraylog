import '../db/database.dart';
import '../result.dart';

class OutboxService {
  const OutboxService(this.database);

  final AppDatabase database;

  Future<Result<void>> enqueue({
    required String id,
    required String entity,
    required String operation,
    required String payload,
  }) async {
    return const Success(null);
  }

  Future<Result<void>> processQueue() async {
    return const Success(null);
  }
}

