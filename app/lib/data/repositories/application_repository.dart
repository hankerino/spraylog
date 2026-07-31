import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/errors.dart';
import '../../core/result.dart';
import '../models/application.dart';

class ApplicationRepository {
  const ApplicationRepository(this.database);

  final AppDatabase database;

  Future<Result<void>> save(
    ApplicationModel application,
  ) async {
    try {
      await database.into(
        database.applications,
      ).insert(
            ApplicationsCompanion.insert(
              id: application.id,
              companyId: application.companyId,
              applicatorId: application.applicatorId,
              customerId: Value(application.customerId),
              siteId: Value(application.siteId),
              state: application.state,
              appliedAt: application.appliedAt,
              productId: application.productId,
              epaRegNo: application.epaRegNo,
              brandName: application.brandName,
              rateValue: application.rateValue,
              rateUnit: application.rateUnit,
              totalAmountValue: Value(application.totalAmountValue),
              totalAmountUnit: Value(application.totalAmountUnit),
              areaValue: application.areaValue,
              areaUnit: application.areaUnit,
              targetPest: Value(application.targetPest),
              applicationMethod: Value(application.applicationMethod),
              lat: Value(application.lat),
              lng: Value(application.lng),
              tempF: Value(application.tempF),
              windMph: Value(application.windMph),
              windDirection: Value(application.windDirection),
              weatherSource: Value(application.weatherSource),
              transcript: Value(application.transcript),
              extractionModel: Value(application.extractionModel),
              extractionConfidence: Value(application.extractionConfidence),
              rateFlag: Value(application.rateFlag),
              overrideReason: Value(application.overrideReason),
              signedAt: Value(application.signedAt),
              signedBy: Value(application.signedBy),
              recordHash: Value(application.recordHash),
              prevHash: Value(application.prevHash),
            ),
          );

      return const Success(null);
    } catch (error) {
      return Failure(DatabaseError('failed to save application: $error'));
    }
  }

  Future<Result<List<ApplicationModel>>> getAll({
    String? companyId,
  }) async {
    try {
      final query = database.select(database.applications)
        ..orderBy(
          [(row) => OrderingTerm.desc(row.appliedAt)],
        );
      if (companyId != null) {
        query.where((row) => row.companyId.equals(companyId));
      }
      final rows = await query.get();

      return Success(
        rows.map(ApplicationModel.fromDrift).toList(),
      );
    } catch (error) {
      return Failure(DatabaseError('failed to load applications: $error'));
    }
  }

  Future<Result<ApplicationModel?>> getById(
    String id,
  ) async {
    try {
      final row = await (database.select(database.applications)
            ..where((rows) => rows.id.equals(id)))
          .getSingleOrNull();

      return Success(
        row == null ? null : ApplicationModel.fromDrift(row),
      );
    } catch (error) {
      return Failure(DatabaseError('failed to load application: $error'));
    }
  }

  /// recordHash of the most recently signed application for [companyId],
  /// or null when the company has no signed records yet (chain genesis).
  Future<Result<String?>> latestSignedHash(
    String companyId,
  ) async {
    try {
      final row = await (database.select(database.applications)
            ..where(
              (rows) =>
                  rows.companyId.equals(companyId) &
                  rows.signedAt.isNotNull() &
                  rows.recordHash.isNotNull(),
            )
            ..orderBy(
              [
                (rows) => OrderingTerm.desc(rows.signedAt),
                (rows) => OrderingTerm.desc(rows.id),
              ],
            )
            ..limit(1))
          .getSingleOrNull();

      return Success(row?.recordHash);
    } catch (error) {
      return Failure(DatabaseError('failed to load latest hash: $error'));
    }
  }
}
