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

@DriftDatabase(
  tables: [
    OutboxItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
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
