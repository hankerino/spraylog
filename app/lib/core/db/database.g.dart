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

class $ApplicationsTable extends Applications
    with TableInfo<$ApplicationsTable, Application> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApplicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _companyIdMeta =
      const VerificationMeta('companyId');
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
      'company_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _applicatorIdMeta =
      const VerificationMeta('applicatorId');
  @override
  late final GeneratedColumn<String> applicatorId = GeneratedColumn<String>(
      'applicator_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appliedAtMeta =
      const VerificationMeta('appliedAt');
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
      'applied_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _epaRegNoMeta =
      const VerificationMeta('epaRegNo');
  @override
  late final GeneratedColumn<String> epaRegNo = GeneratedColumn<String>(
      'epa_reg_no', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandNameMeta =
      const VerificationMeta('brandName');
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
      'brand_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rateValueMeta =
      const VerificationMeta('rateValue');
  @override
  late final GeneratedColumn<double> rateValue = GeneratedColumn<double>(
      'rate_value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _rateUnitMeta =
      const VerificationMeta('rateUnit');
  @override
  late final GeneratedColumn<String> rateUnit = GeneratedColumn<String>(
      'rate_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _areaValueMeta =
      const VerificationMeta('areaValue');
  @override
  late final GeneratedColumn<double> areaValue = GeneratedColumn<double>(
      'area_value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _areaUnitMeta =
      const VerificationMeta('areaUnit');
  @override
  late final GeneratedColumn<String> areaUnit = GeneratedColumn<String>(
      'area_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _signedAtMeta =
      const VerificationMeta('signedAt');
  @override
  late final GeneratedColumn<DateTime> signedAt = GeneratedColumn<DateTime>(
      'signed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _signedByMeta =
      const VerificationMeta('signedBy');
  @override
  late final GeneratedColumn<String> signedBy = GeneratedColumn<String>(
      'signed_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordHashMeta =
      const VerificationMeta('recordHash');
  @override
  late final GeneratedColumn<String> recordHash = GeneratedColumn<String>(
      'record_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prevHashMeta =
      const VerificationMeta('prevHash');
  @override
  late final GeneratedColumn<String> prevHash = GeneratedColumn<String>(
      'prev_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        companyId,
        applicatorId,
        state,
        appliedAt,
        productId,
        epaRegNo,
        brandName,
        rateValue,
        rateUnit,
        areaValue,
        areaUnit,
        signedAt,
        signedBy,
        recordHash,
        prevHash
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'applications';
  @override
  VerificationContext validateIntegrity(Insertable<Application> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(_companyIdMeta,
          companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta));
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('applicator_id')) {
      context.handle(
          _applicatorIdMeta,
          applicatorId.isAcceptableOrUnknown(
              data['applicator_id']!, _applicatorIdMeta));
    } else if (isInserting) {
      context.missing(_applicatorIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(_appliedAtMeta,
          appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta));
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('epa_reg_no')) {
      context.handle(_epaRegNoMeta,
          epaRegNo.isAcceptableOrUnknown(data['epa_reg_no']!, _epaRegNoMeta));
    } else if (isInserting) {
      context.missing(_epaRegNoMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(_brandNameMeta,
          brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta));
    } else if (isInserting) {
      context.missing(_brandNameMeta);
    }
    if (data.containsKey('rate_value')) {
      context.handle(_rateValueMeta,
          rateValue.isAcceptableOrUnknown(data['rate_value']!, _rateValueMeta));
    } else if (isInserting) {
      context.missing(_rateValueMeta);
    }
    if (data.containsKey('rate_unit')) {
      context.handle(_rateUnitMeta,
          rateUnit.isAcceptableOrUnknown(data['rate_unit']!, _rateUnitMeta));
    } else if (isInserting) {
      context.missing(_rateUnitMeta);
    }
    if (data.containsKey('area_value')) {
      context.handle(_areaValueMeta,
          areaValue.isAcceptableOrUnknown(data['area_value']!, _areaValueMeta));
    } else if (isInserting) {
      context.missing(_areaValueMeta);
    }
    if (data.containsKey('area_unit')) {
      context.handle(_areaUnitMeta,
          areaUnit.isAcceptableOrUnknown(data['area_unit']!, _areaUnitMeta));
    } else if (isInserting) {
      context.missing(_areaUnitMeta);
    }
    if (data.containsKey('signed_at')) {
      context.handle(_signedAtMeta,
          signedAt.isAcceptableOrUnknown(data['signed_at']!, _signedAtMeta));
    }
    if (data.containsKey('signed_by')) {
      context.handle(_signedByMeta,
          signedBy.isAcceptableOrUnknown(data['signed_by']!, _signedByMeta));
    }
    if (data.containsKey('record_hash')) {
      context.handle(
          _recordHashMeta,
          recordHash.isAcceptableOrUnknown(
              data['record_hash']!, _recordHashMeta));
    }
    if (data.containsKey('prev_hash')) {
      context.handle(_prevHashMeta,
          prevHash.isAcceptableOrUnknown(data['prev_hash']!, _prevHashMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Application map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Application(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      companyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company_id'])!,
      applicatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}applicator_id'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      appliedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}applied_at'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      epaRegNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}epa_reg_no'])!,
      brandName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand_name'])!,
      rateValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rate_value'])!,
      rateUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rate_unit'])!,
      areaValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}area_value'])!,
      areaUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area_unit'])!,
      signedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}signed_at']),
      signedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signed_by']),
      recordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_hash']),
      prevHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prev_hash']),
    );
  }

  @override
  $ApplicationsTable createAlias(String alias) {
    return $ApplicationsTable(attachedDatabase, alias);
  }
}

class Application extends DataClass implements Insertable<Application> {
  final String id;
  final String companyId;
  final String applicatorId;
  final String state;
  final DateTime appliedAt;
  final String productId;
  final String epaRegNo;
  final String brandName;
  final double rateValue;
  final String rateUnit;
  final double areaValue;
  final String areaUnit;
  final DateTime? signedAt;
  final String? signedBy;
  final String? recordHash;
  final String? prevHash;
  const Application(
      {required this.id,
      required this.companyId,
      required this.applicatorId,
      required this.state,
      required this.appliedAt,
      required this.productId,
      required this.epaRegNo,
      required this.brandName,
      required this.rateValue,
      required this.rateUnit,
      required this.areaValue,
      required this.areaUnit,
      this.signedAt,
      this.signedBy,
      this.recordHash,
      this.prevHash});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['applicator_id'] = Variable<String>(applicatorId);
    map['state'] = Variable<String>(state);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    map['product_id'] = Variable<String>(productId);
    map['epa_reg_no'] = Variable<String>(epaRegNo);
    map['brand_name'] = Variable<String>(brandName);
    map['rate_value'] = Variable<double>(rateValue);
    map['rate_unit'] = Variable<String>(rateUnit);
    map['area_value'] = Variable<double>(areaValue);
    map['area_unit'] = Variable<String>(areaUnit);
    if (!nullToAbsent || signedAt != null) {
      map['signed_at'] = Variable<DateTime>(signedAt);
    }
    if (!nullToAbsent || signedBy != null) {
      map['signed_by'] = Variable<String>(signedBy);
    }
    if (!nullToAbsent || recordHash != null) {
      map['record_hash'] = Variable<String>(recordHash);
    }
    if (!nullToAbsent || prevHash != null) {
      map['prev_hash'] = Variable<String>(prevHash);
    }
    return map;
  }

  ApplicationsCompanion toCompanion(bool nullToAbsent) {
    return ApplicationsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      applicatorId: Value(applicatorId),
      state: Value(state),
      appliedAt: Value(appliedAt),
      productId: Value(productId),
      epaRegNo: Value(epaRegNo),
      brandName: Value(brandName),
      rateValue: Value(rateValue),
      rateUnit: Value(rateUnit),
      areaValue: Value(areaValue),
      areaUnit: Value(areaUnit),
      signedAt: signedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(signedAt),
      signedBy: signedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(signedBy),
      recordHash: recordHash == null && nullToAbsent
          ? const Value.absent()
          : Value(recordHash),
      prevHash: prevHash == null && nullToAbsent
          ? const Value.absent()
          : Value(prevHash),
    );
  }

  factory Application.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Application(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      applicatorId: serializer.fromJson<String>(json['applicatorId']),
      state: serializer.fromJson<String>(json['state']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
      productId: serializer.fromJson<String>(json['productId']),
      epaRegNo: serializer.fromJson<String>(json['epaRegNo']),
      brandName: serializer.fromJson<String>(json['brandName']),
      rateValue: serializer.fromJson<double>(json['rateValue']),
      rateUnit: serializer.fromJson<String>(json['rateUnit']),
      areaValue: serializer.fromJson<double>(json['areaValue']),
      areaUnit: serializer.fromJson<String>(json['areaUnit']),
      signedAt: serializer.fromJson<DateTime?>(json['signedAt']),
      signedBy: serializer.fromJson<String?>(json['signedBy']),
      recordHash: serializer.fromJson<String?>(json['recordHash']),
      prevHash: serializer.fromJson<String?>(json['prevHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'applicatorId': serializer.toJson<String>(applicatorId),
      'state': serializer.toJson<String>(state),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
      'productId': serializer.toJson<String>(productId),
      'epaRegNo': serializer.toJson<String>(epaRegNo),
      'brandName': serializer.toJson<String>(brandName),
      'rateValue': serializer.toJson<double>(rateValue),
      'rateUnit': serializer.toJson<String>(rateUnit),
      'areaValue': serializer.toJson<double>(areaValue),
      'areaUnit': serializer.toJson<String>(areaUnit),
      'signedAt': serializer.toJson<DateTime?>(signedAt),
      'signedBy': serializer.toJson<String?>(signedBy),
      'recordHash': serializer.toJson<String?>(recordHash),
      'prevHash': serializer.toJson<String?>(prevHash),
    };
  }

  Application copyWith(
          {String? id,
          String? companyId,
          String? applicatorId,
          String? state,
          DateTime? appliedAt,
          String? productId,
          String? epaRegNo,
          String? brandName,
          double? rateValue,
          String? rateUnit,
          double? areaValue,
          String? areaUnit,
          Value<DateTime?> signedAt = const Value.absent(),
          Value<String?> signedBy = const Value.absent(),
          Value<String?> recordHash = const Value.absent(),
          Value<String?> prevHash = const Value.absent()}) =>
      Application(
        id: id ?? this.id,
        companyId: companyId ?? this.companyId,
        applicatorId: applicatorId ?? this.applicatorId,
        state: state ?? this.state,
        appliedAt: appliedAt ?? this.appliedAt,
        productId: productId ?? this.productId,
        epaRegNo: epaRegNo ?? this.epaRegNo,
        brandName: brandName ?? this.brandName,
        rateValue: rateValue ?? this.rateValue,
        rateUnit: rateUnit ?? this.rateUnit,
        areaValue: areaValue ?? this.areaValue,
        areaUnit: areaUnit ?? this.areaUnit,
        signedAt: signedAt.present ? signedAt.value : this.signedAt,
        signedBy: signedBy.present ? signedBy.value : this.signedBy,
        recordHash: recordHash.present ? recordHash.value : this.recordHash,
        prevHash: prevHash.present ? prevHash.value : this.prevHash,
      );
  Application copyWithCompanion(ApplicationsCompanion data) {
    return Application(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      applicatorId: data.applicatorId.present
          ? data.applicatorId.value
          : this.applicatorId,
      state: data.state.present ? data.state.value : this.state,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      productId: data.productId.present ? data.productId.value : this.productId,
      epaRegNo: data.epaRegNo.present ? data.epaRegNo.value : this.epaRegNo,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      rateValue: data.rateValue.present ? data.rateValue.value : this.rateValue,
      rateUnit: data.rateUnit.present ? data.rateUnit.value : this.rateUnit,
      areaValue: data.areaValue.present ? data.areaValue.value : this.areaValue,
      areaUnit: data.areaUnit.present ? data.areaUnit.value : this.areaUnit,
      signedAt: data.signedAt.present ? data.signedAt.value : this.signedAt,
      signedBy: data.signedBy.present ? data.signedBy.value : this.signedBy,
      recordHash:
          data.recordHash.present ? data.recordHash.value : this.recordHash,
      prevHash: data.prevHash.present ? data.prevHash.value : this.prevHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Application(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('applicatorId: $applicatorId, ')
          ..write('state: $state, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('productId: $productId, ')
          ..write('epaRegNo: $epaRegNo, ')
          ..write('brandName: $brandName, ')
          ..write('rateValue: $rateValue, ')
          ..write('rateUnit: $rateUnit, ')
          ..write('areaValue: $areaValue, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('signedAt: $signedAt, ')
          ..write('signedBy: $signedBy, ')
          ..write('recordHash: $recordHash, ')
          ..write('prevHash: $prevHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      companyId,
      applicatorId,
      state,
      appliedAt,
      productId,
      epaRegNo,
      brandName,
      rateValue,
      rateUnit,
      areaValue,
      areaUnit,
      signedAt,
      signedBy,
      recordHash,
      prevHash);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Application &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.applicatorId == this.applicatorId &&
          other.state == this.state &&
          other.appliedAt == this.appliedAt &&
          other.productId == this.productId &&
          other.epaRegNo == this.epaRegNo &&
          other.brandName == this.brandName &&
          other.rateValue == this.rateValue &&
          other.rateUnit == this.rateUnit &&
          other.areaValue == this.areaValue &&
          other.areaUnit == this.areaUnit &&
          other.signedAt == this.signedAt &&
          other.signedBy == this.signedBy &&
          other.recordHash == this.recordHash &&
          other.prevHash == this.prevHash);
}

class ApplicationsCompanion extends UpdateCompanion<Application> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> applicatorId;
  final Value<String> state;
  final Value<DateTime> appliedAt;
  final Value<String> productId;
  final Value<String> epaRegNo;
  final Value<String> brandName;
  final Value<double> rateValue;
  final Value<String> rateUnit;
  final Value<double> areaValue;
  final Value<String> areaUnit;
  final Value<DateTime?> signedAt;
  final Value<String?> signedBy;
  final Value<String?> recordHash;
  final Value<String?> prevHash;
  final Value<int> rowid;
  const ApplicationsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.applicatorId = const Value.absent(),
    this.state = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.productId = const Value.absent(),
    this.epaRegNo = const Value.absent(),
    this.brandName = const Value.absent(),
    this.rateValue = const Value.absent(),
    this.rateUnit = const Value.absent(),
    this.areaValue = const Value.absent(),
    this.areaUnit = const Value.absent(),
    this.signedAt = const Value.absent(),
    this.signedBy = const Value.absent(),
    this.recordHash = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApplicationsCompanion.insert({
    required String id,
    required String companyId,
    required String applicatorId,
    required String state,
    required DateTime appliedAt,
    required String productId,
    required String epaRegNo,
    required String brandName,
    required double rateValue,
    required String rateUnit,
    required double areaValue,
    required String areaUnit,
    this.signedAt = const Value.absent(),
    this.signedBy = const Value.absent(),
    this.recordHash = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        companyId = Value(companyId),
        applicatorId = Value(applicatorId),
        state = Value(state),
        appliedAt = Value(appliedAt),
        productId = Value(productId),
        epaRegNo = Value(epaRegNo),
        brandName = Value(brandName),
        rateValue = Value(rateValue),
        rateUnit = Value(rateUnit),
        areaValue = Value(areaValue),
        areaUnit = Value(areaUnit);
  static Insertable<Application> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? applicatorId,
    Expression<String>? state,
    Expression<DateTime>? appliedAt,
    Expression<String>? productId,
    Expression<String>? epaRegNo,
    Expression<String>? brandName,
    Expression<double>? rateValue,
    Expression<String>? rateUnit,
    Expression<double>? areaValue,
    Expression<String>? areaUnit,
    Expression<DateTime>? signedAt,
    Expression<String>? signedBy,
    Expression<String>? recordHash,
    Expression<String>? prevHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (applicatorId != null) 'applicator_id': applicatorId,
      if (state != null) 'state': state,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (productId != null) 'product_id': productId,
      if (epaRegNo != null) 'epa_reg_no': epaRegNo,
      if (brandName != null) 'brand_name': brandName,
      if (rateValue != null) 'rate_value': rateValue,
      if (rateUnit != null) 'rate_unit': rateUnit,
      if (areaValue != null) 'area_value': areaValue,
      if (areaUnit != null) 'area_unit': areaUnit,
      if (signedAt != null) 'signed_at': signedAt,
      if (signedBy != null) 'signed_by': signedBy,
      if (recordHash != null) 'record_hash': recordHash,
      if (prevHash != null) 'prev_hash': prevHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApplicationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? companyId,
      Value<String>? applicatorId,
      Value<String>? state,
      Value<DateTime>? appliedAt,
      Value<String>? productId,
      Value<String>? epaRegNo,
      Value<String>? brandName,
      Value<double>? rateValue,
      Value<String>? rateUnit,
      Value<double>? areaValue,
      Value<String>? areaUnit,
      Value<DateTime?>? signedAt,
      Value<String?>? signedBy,
      Value<String?>? recordHash,
      Value<String?>? prevHash,
      Value<int>? rowid}) {
    return ApplicationsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      applicatorId: applicatorId ?? this.applicatorId,
      state: state ?? this.state,
      appliedAt: appliedAt ?? this.appliedAt,
      productId: productId ?? this.productId,
      epaRegNo: epaRegNo ?? this.epaRegNo,
      brandName: brandName ?? this.brandName,
      rateValue: rateValue ?? this.rateValue,
      rateUnit: rateUnit ?? this.rateUnit,
      areaValue: areaValue ?? this.areaValue,
      areaUnit: areaUnit ?? this.areaUnit,
      signedAt: signedAt ?? this.signedAt,
      signedBy: signedBy ?? this.signedBy,
      recordHash: recordHash ?? this.recordHash,
      prevHash: prevHash ?? this.prevHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (applicatorId.present) {
      map['applicator_id'] = Variable<String>(applicatorId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (epaRegNo.present) {
      map['epa_reg_no'] = Variable<String>(epaRegNo.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (rateValue.present) {
      map['rate_value'] = Variable<double>(rateValue.value);
    }
    if (rateUnit.present) {
      map['rate_unit'] = Variable<String>(rateUnit.value);
    }
    if (areaValue.present) {
      map['area_value'] = Variable<double>(areaValue.value);
    }
    if (areaUnit.present) {
      map['area_unit'] = Variable<String>(areaUnit.value);
    }
    if (signedAt.present) {
      map['signed_at'] = Variable<DateTime>(signedAt.value);
    }
    if (signedBy.present) {
      map['signed_by'] = Variable<String>(signedBy.value);
    }
    if (recordHash.present) {
      map['record_hash'] = Variable<String>(recordHash.value);
    }
    if (prevHash.present) {
      map['prev_hash'] = Variable<String>(prevHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApplicationsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('applicatorId: $applicatorId, ')
          ..write('state: $state, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('productId: $productId, ')
          ..write('epaRegNo: $epaRegNo, ')
          ..write('brandName: $brandName, ')
          ..write('rateValue: $rateValue, ')
          ..write('rateUnit: $rateUnit, ')
          ..write('areaValue: $areaValue, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('signedAt: $signedAt, ')
          ..write('signedBy: $signedBy, ')
          ..write('recordHash: $recordHash, ')
          ..write('prevHash: $prevHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OutboxItemsTable outboxItems = $OutboxItemsTable(this);
  late final $ApplicationsTable applications = $ApplicationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [outboxItems, applications];
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
typedef $$ApplicationsTableCreateCompanionBuilder = ApplicationsCompanion
    Function({
  required String id,
  required String companyId,
  required String applicatorId,
  required String state,
  required DateTime appliedAt,
  required String productId,
  required String epaRegNo,
  required String brandName,
  required double rateValue,
  required String rateUnit,
  required double areaValue,
  required String areaUnit,
  Value<DateTime?> signedAt,
  Value<String?> signedBy,
  Value<String?> recordHash,
  Value<String?> prevHash,
  Value<int> rowid,
});
typedef $$ApplicationsTableUpdateCompanionBuilder = ApplicationsCompanion
    Function({
  Value<String> id,
  Value<String> companyId,
  Value<String> applicatorId,
  Value<String> state,
  Value<DateTime> appliedAt,
  Value<String> productId,
  Value<String> epaRegNo,
  Value<String> brandName,
  Value<double> rateValue,
  Value<String> rateUnit,
  Value<double> areaValue,
  Value<String> areaUnit,
  Value<DateTime?> signedAt,
  Value<String?> signedBy,
  Value<String?> recordHash,
  Value<String?> prevHash,
  Value<int> rowid,
});

class $$ApplicationsTableFilterComposer
    extends Composer<_$AppDatabase, $ApplicationsTable> {
  $$ApplicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get companyId => $composableBuilder(
      column: $table.companyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get applicatorId => $composableBuilder(
      column: $table.applicatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
      column: $table.appliedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get epaRegNo => $composableBuilder(
      column: $table.epaRegNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brandName => $composableBuilder(
      column: $table.brandName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rateValue => $composableBuilder(
      column: $table.rateValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rateUnit => $composableBuilder(
      column: $table.rateUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get areaValue => $composableBuilder(
      column: $table.areaValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get areaUnit => $composableBuilder(
      column: $table.areaUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get signedAt => $composableBuilder(
      column: $table.signedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get signedBy => $composableBuilder(
      column: $table.signedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordHash => $composableBuilder(
      column: $table.recordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prevHash => $composableBuilder(
      column: $table.prevHash, builder: (column) => ColumnFilters(column));
}

class $$ApplicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ApplicationsTable> {
  $$ApplicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get companyId => $composableBuilder(
      column: $table.companyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get applicatorId => $composableBuilder(
      column: $table.applicatorId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
      column: $table.appliedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get epaRegNo => $composableBuilder(
      column: $table.epaRegNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brandName => $composableBuilder(
      column: $table.brandName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rateValue => $composableBuilder(
      column: $table.rateValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rateUnit => $composableBuilder(
      column: $table.rateUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get areaValue => $composableBuilder(
      column: $table.areaValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get areaUnit => $composableBuilder(
      column: $table.areaUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get signedAt => $composableBuilder(
      column: $table.signedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get signedBy => $composableBuilder(
      column: $table.signedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordHash => $composableBuilder(
      column: $table.recordHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prevHash => $composableBuilder(
      column: $table.prevHash, builder: (column) => ColumnOrderings(column));
}

class $$ApplicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApplicationsTable> {
  $$ApplicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get applicatorId => $composableBuilder(
      column: $table.applicatorId, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get epaRegNo =>
      $composableBuilder(column: $table.epaRegNo, builder: (column) => column);

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<double> get rateValue =>
      $composableBuilder(column: $table.rateValue, builder: (column) => column);

  GeneratedColumn<String> get rateUnit =>
      $composableBuilder(column: $table.rateUnit, builder: (column) => column);

  GeneratedColumn<double> get areaValue =>
      $composableBuilder(column: $table.areaValue, builder: (column) => column);

  GeneratedColumn<String> get areaUnit =>
      $composableBuilder(column: $table.areaUnit, builder: (column) => column);

  GeneratedColumn<DateTime> get signedAt =>
      $composableBuilder(column: $table.signedAt, builder: (column) => column);

  GeneratedColumn<String> get signedBy =>
      $composableBuilder(column: $table.signedBy, builder: (column) => column);

  GeneratedColumn<String> get recordHash => $composableBuilder(
      column: $table.recordHash, builder: (column) => column);

  GeneratedColumn<String> get prevHash =>
      $composableBuilder(column: $table.prevHash, builder: (column) => column);
}

class $$ApplicationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ApplicationsTable,
    Application,
    $$ApplicationsTableFilterComposer,
    $$ApplicationsTableOrderingComposer,
    $$ApplicationsTableAnnotationComposer,
    $$ApplicationsTableCreateCompanionBuilder,
    $$ApplicationsTableUpdateCompanionBuilder,
    (
      Application,
      BaseReferences<_$AppDatabase, $ApplicationsTable, Application>
    ),
    Application,
    PrefetchHooks Function()> {
  $$ApplicationsTableTableManager(_$AppDatabase db, $ApplicationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApplicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApplicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApplicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> companyId = const Value.absent(),
            Value<String> applicatorId = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<DateTime> appliedAt = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> epaRegNo = const Value.absent(),
            Value<String> brandName = const Value.absent(),
            Value<double> rateValue = const Value.absent(),
            Value<String> rateUnit = const Value.absent(),
            Value<double> areaValue = const Value.absent(),
            Value<String> areaUnit = const Value.absent(),
            Value<DateTime?> signedAt = const Value.absent(),
            Value<String?> signedBy = const Value.absent(),
            Value<String?> recordHash = const Value.absent(),
            Value<String?> prevHash = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ApplicationsCompanion(
            id: id,
            companyId: companyId,
            applicatorId: applicatorId,
            state: state,
            appliedAt: appliedAt,
            productId: productId,
            epaRegNo: epaRegNo,
            brandName: brandName,
            rateValue: rateValue,
            rateUnit: rateUnit,
            areaValue: areaValue,
            areaUnit: areaUnit,
            signedAt: signedAt,
            signedBy: signedBy,
            recordHash: recordHash,
            prevHash: prevHash,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String companyId,
            required String applicatorId,
            required String state,
            required DateTime appliedAt,
            required String productId,
            required String epaRegNo,
            required String brandName,
            required double rateValue,
            required String rateUnit,
            required double areaValue,
            required String areaUnit,
            Value<DateTime?> signedAt = const Value.absent(),
            Value<String?> signedBy = const Value.absent(),
            Value<String?> recordHash = const Value.absent(),
            Value<String?> prevHash = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ApplicationsCompanion.insert(
            id: id,
            companyId: companyId,
            applicatorId: applicatorId,
            state: state,
            appliedAt: appliedAt,
            productId: productId,
            epaRegNo: epaRegNo,
            brandName: brandName,
            rateValue: rateValue,
            rateUnit: rateUnit,
            areaValue: areaValue,
            areaUnit: areaUnit,
            signedAt: signedAt,
            signedBy: signedBy,
            recordHash: recordHash,
            prevHash: prevHash,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ApplicationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ApplicationsTable,
    Application,
    $$ApplicationsTableFilterComposer,
    $$ApplicationsTableOrderingComposer,
    $$ApplicationsTableAnnotationComposer,
    $$ApplicationsTableCreateCompanionBuilder,
    $$ApplicationsTableUpdateCompanionBuilder,
    (
      Application,
      BaseReferences<_$AppDatabase, $ApplicationsTable, Application>
    ),
    Application,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxItemsTableTableManager get outboxItems =>
      $$OutboxItemsTableTableManager(_db, _db.outboxItems);
  $$ApplicationsTableTableManager get applications =>
      $$ApplicationsTableTableManager(_db, _db.applications);
}
