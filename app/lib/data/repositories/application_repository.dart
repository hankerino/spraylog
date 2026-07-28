import '../../core/db/database.dart';
import '../../core/result.dart';
import '../models/application.dart';

class ApplicationRepository {
  const ApplicationRepository(this.database);

  final AppDatabase database;

  Future<Result<void>> save(
    ApplicationModel application,
  ) async {
    return const Success(null);
  }

  Future<Result<List<ApplicationModel>>> getAll() async {
    return const Success([]);
  }
}
