import 'package:drift/drift.dart';

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

@DriftDatabase(
  tables: [
    OutboxItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}

