// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $OutboxItemsTable extends OutboxItems
    with TableInfo<$OutboxItemsTable, OutboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
      'entity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entity, operation, payload, attempts, nextAttemptAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_items';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(_entityMeta,
          entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    } else if (isInserting) {
      context.missing(_nextAttemptAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at'])!,
    );
  }

  @override
  $OutboxItemsTable createAlias(String alias) {
    return $OutboxItemsTable(attachedDatabase, alias);
  }
}

class OutboxItem extends DataClass implements Insertable<OutboxItem> {
  final String id;
  final String entity;
  final String operation;
  final String payload;
  final int attempts;
  final DateTime nextAttemptAt;
  const OutboxItem(
      {required this.id,
      required this.entity,
      required this.operation,
      required this.payload,
      required this.attempts,
      required this.nextAttemptAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity'] = Variable<String>(entity);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['attempts'] = Variable<int>(attempts);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    return map;
  }

  OutboxItemsCompanion toCompanion(bool nullToAbsent) {
    return OutboxItemsCompanion(
      id: Value(id),
      entity: Value(entity),
      operation: Value(operation),
      payload: Value(payload),
      attempts: Value(attempts),
      nextAttemptAt: Value(nextAttemptAt),
    );
  }

  factory OutboxItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxItem(
      id: serializer.fromJson<String>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entity': serializer.toJson<String>(entity),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
    };
  }

  OutboxItem copyWith(
          {String? id,
          String? entity,
          String? operation,
          String? payload,
          int? attempts,
          DateTime? nextAttemptAt}) =>
      OutboxItem(
        id: id ?? this.id,
        entity: entity ?? this.entity,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        attempts: attempts ?? this.attempts,
        nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      );
  OutboxItem copyWithCompanion(OutboxItemsCompanion data) {
    return OutboxItem(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItem(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entity, operation, payload, attempts, nextAttemptAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxItem &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt);
}

class OutboxItemsCompanion extends UpdateCompanion<OutboxItem> {
  final Value<String> id;
  final Value<String> entity;
  final Value<String> operation;
  final Value<String> payload;
  final Value<int> attempts;
  final Value<DateTime> nextAttemptAt;
  final Value<int> rowid;
  const OutboxItemsCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxItemsCompanion.insert({
    required String id,
    required String entity,
    required String operation,
    required String payload,
    this.attempts = const Value.absent(),
    required DateTime nextAttemptAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entity = Value(entity),
        operation = Value(operation),
        payload = Value(payload),
        nextAttemptAt = Value(nextAttemptAt);
  static Insertable<OutboxItem> custom({
    Expression<String>? id,
    Expression<String>? entity,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entity,
      Value<String>? operation,
      Value<String>? payload,
      Value<int>? attempts,
      Value<DateTime>? nextAttemptAt,
      Value<int>? rowid}) {
    return OutboxItemsCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItemsCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OutboxItemsTable outboxItems = $OutboxItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [outboxItems];
}

typedef $$OutboxItemsTableCreateCompanionBuilder = OutboxItemsCompanion
    Function({
  required String id,
  required String entity,
  required String operation,
  required String payload,
  Value<int> attempts,
  required DateTime nextAttemptAt,
  Value<int> rowid,
});
typedef $$OutboxItemsTableUpdateCompanionBuilder = OutboxItemsCompanion
    Function({
  Value<String> id,
  Value<String> entity,
  Value<String> operation,
  Value<String> payload,
  Value<int> attempts,
  Value<DateTime> nextAttemptAt,
  Value<int> rowid,
});

class $$OutboxItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxItemsTable> {
  $$OutboxItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxItemsTable> {
  $$OutboxItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));
}

class $$OutboxItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxItemsTable> {
  $$OutboxItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);
}

class $$OutboxItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxItemsTable,
    OutboxItem,
    $$OutboxItemsTableFilterComposer,
    $$OutboxItemsTableOrderingComposer,
    $$OutboxItemsTableAnnotationComposer,
    $$OutboxItemsTableCreateCompanionBuilder,
    $$OutboxItemsTableUpdateCompanionBuilder,
    (OutboxItem, BaseReferences<_$AppDatabase, $OutboxItemsTable, OutboxItem>),
    OutboxItem,
    PrefetchHooks Function()> {
  $$OutboxItemsTableTableManager(_$AppDatabase db, $OutboxItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entity = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime> nextAttemptAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxItemsCompanion(
            id: id,
            entity: entity,
            operation: operation,
            payload: payload,
            attempts: attempts,
            nextAttemptAt: nextAttemptAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entity,
            required String operation,
            required String payload,
            Value<int> attempts = const Value.absent(),
            required DateTime nextAttemptAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxItemsCompanion.insert(
            id: id,
            entity: entity,
            operation: operation,
            payload: payload,
            attempts: attempts,
            nextAttemptAt: nextAttemptAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxItemsTable,
    OutboxItem,
    $$OutboxItemsTableFilterComposer,
    $$OutboxItemsTableOrderingComposer,
    $$OutboxItemsTableAnnotationComposer,
    $$OutboxItemsTableCreateCompanionBuilder,
    $$OutboxItemsTableUpdateCompanionBuilder,
    (OutboxItem, BaseReferences<_$AppDatabase, $OutboxItemsTable, OutboxItem>),
    OutboxItem,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxItemsTableTableManager get outboxItems =>
      $$OutboxItemsTableTableManager(_db, _db.outboxItems);
}
