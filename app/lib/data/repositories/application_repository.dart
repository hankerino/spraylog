import '../../core/db/database.dart';
import '../../core/result.dart';
import '../models/application.dart';

class ApplicationRepository {
  const ApplicationRepository(this.database);

  final AppDatabase database;

  Future<Result<void>> save(
    ApplicationModel application,
  ) async {
    await database.into(
      database.applications,
    ).insert(
      ApplicationsCompanion.insert(
        id: application.id,
        companyId: application.companyId,
        applicatorId: application.applicatorId,
        state: application.state,
        appliedAt: application.appliedAt,
        productId: application.productId,
        epaRegNo: application.epaRegNo,
        brandName: application.brandName,
        rateValue: application.rateValue,
        rateUnit: application.rateUnit,
        areaValue: application.areaValue,
        areaUnit: application.areaUnit,
      ),
    );

    return const Success(null);
  }

  Future<Result<List<ApplicationModel>>> getAll() async {
    return const Success([]);
  }
}
