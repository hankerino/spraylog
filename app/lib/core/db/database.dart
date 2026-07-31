import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class OutboxItems extends Table {
  TextColumn get id => text()();

  TextColumn get entity => text()();

  TextColumn get operation => text()();

  TextColumn get payload => text()();

  IntColumn get attempts => integer().withDefault(
        const Constant(0),
      )();

  DateTimeColumn get nextAttemptAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local mirror of the remote `applications` record, per spec §2.
/// Signed rows are immutable (enforced remotely by trigger).
class Applications extends Table {
  TextColumn get id => text()();

  TextColumn get companyId => text()();

  TextColumn get applicatorId => text()();

  TextColumn get customerId => text().nullable()();

  TextColumn get siteId => text().nullable()();

  TextColumn get state => text()();

  DateTimeColumn get appliedAt => dateTime()();

  TextColumn get productId => text()();

  TextColumn get epaRegNo => text()();

  TextColumn get brandName => text()();

  RealColumn get rateValue => real()();

  TextColumn get rateUnit => text()();

  RealColumn get totalAmountValue => real().nullable()();

  TextColumn get totalAmountUnit => text().nullable()();

  RealColumn get areaValue => real()();

  TextColumn get areaUnit => text()();

  TextColumn get targetPest => text().nullable()();

  TextColumn get applicationMethod => text().nullable()();

  RealColumn get lat => real().nullable()();

  RealColumn get lng => real().nullable()();

  RealColumn get tempF => real().nullable()();

  RealColumn get windMph => real().nullable()();

  TextColumn get windDirection => text().nullable()();

  TextColumn get weatherSource => text().nullable()();

  TextColumn get transcript => text().nullable()();

  TextColumn get extractionModel => text().nullable()();

  RealColumn get extractionConfidence => real().nullable()();

  TextColumn get rateFlag => text().nullable()();

  TextColumn get overrideReason => text().nullable()();

  DateTimeColumn get signedAt => dateTime().nullable()();

  TextColumn get signedBy => text().nullable()();

  TextColumn get recordHash => text().nullable()();

  TextColumn get prevHash => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    OutboxItems,
    Applications,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            final m = migrator;
            await m.addColumn(applications, applications.customerId);
            await m.addColumn(applications, applications.siteId);
            await m.addColumn(applications, applications.totalAmountValue);
            await m.addColumn(applications, applications.totalAmountUnit);
            await m.addColumn(applications, applications.targetPest);
            await m.addColumn(applications, applications.applicationMethod);
            await m.addColumn(applications, applications.lat);
            await m.addColumn(applications, applications.lng);
            await m.addColumn(applications, applications.tempF);
            await m.addColumn(applications, applications.windMph);
            await m.addColumn(applications, applications.windDirection);
            await m.addColumn(applications, applications.weatherSource);
            await m.addColumn(applications, applications.transcript);
            await m.addColumn(applications, applications.extractionModel);
            await m.addColumn(applications, applications.extractionConfidence);
            await m.addColumn(applications, applications.rateFlag);
            await m.addColumn(applications, applications.overrideReason);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      p.join(
        directory.path,
        'spraylog.db',
      ),
    );

    return NativeDatabase.createInBackground(file);
  });
}
