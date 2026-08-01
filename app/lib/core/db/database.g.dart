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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    operation,
    payload,
    attempts,
    nextAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      )!,
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
  const OutboxItem({
    required this.id,
    required this.entity,
    required this.operation,
    required this.payload,
    required this.attempts,
    required this.nextAttemptAt,
  });
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

  factory OutboxItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  OutboxItem copyWith({
    String? id,
    String? entity,
    String? operation,
    String? payload,
    int? attempts,
    DateTime? nextAttemptAt,
  }) => OutboxItem(
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
  }) : id = Value(id),
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

  OutboxItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? entity,
    Value<String>? operation,
    Value<String>? payload,
    Value<int>? attempts,
    Value<DateTime>? nextAttemptAt,
    Value<int>? rowid,
  }) {
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _applicatorIdMeta = const VerificationMeta(
    'applicatorId',
  );
  @override
  late final GeneratedColumn<String> applicatorId = GeneratedColumn<String>(
    'applicator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _epaRegNoMeta = const VerificationMeta(
    'epaRegNo',
  );
  @override
  late final GeneratedColumn<String> epaRegNo = GeneratedColumn<String>(
    'epa_reg_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateValueMeta = const VerificationMeta(
    'rateValue',
  );
  @override
  late final GeneratedColumn<double> rateValue = GeneratedColumn<double>(
    'rate_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateUnitMeta = const VerificationMeta(
    'rateUnit',
  );
  @override
  late final GeneratedColumn<String> rateUnit = GeneratedColumn<String>(
    'rate_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountValueMeta = const VerificationMeta(
    'totalAmountValue',
  );
  @override
  late final GeneratedColumn<double> totalAmountValue = GeneratedColumn<double>(
    'total_amount_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountUnitMeta = const VerificationMeta(
    'totalAmountUnit',
  );
  @override
  late final GeneratedColumn<String> totalAmountUnit = GeneratedColumn<String>(
    'total_amount_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaValueMeta = const VerificationMeta(
    'areaValue',
  );
  @override
  late final GeneratedColumn<double> areaValue = GeneratedColumn<double>(
    'area_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaUnitMeta = const VerificationMeta(
    'areaUnit',
  );
  @override
  late final GeneratedColumn<String> areaUnit = GeneratedColumn<String>(
    'area_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetPestMeta = const VerificationMeta(
    'targetPest',
  );
  @override
  late final GeneratedColumn<String> targetPest = GeneratedColumn<String>(
    'target_pest',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _applicationMethodMeta = const VerificationMeta(
    'applicationMethod',
  );
  @override
  late final GeneratedColumn<String> applicationMethod =
      GeneratedColumn<String>(
        'application_method',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tempFMeta = const VerificationMeta('tempF');
  @override
  late final GeneratedColumn<double> tempF = GeneratedColumn<double>(
    'temp_f',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _windMphMeta = const VerificationMeta(
    'windMph',
  );
  @override
  late final GeneratedColumn<double> windMph = GeneratedColumn<double>(
    'wind_mph',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _windDirectionMeta = const VerificationMeta(
    'windDirection',
  );
  @override
  late final GeneratedColumn<String> windDirection = GeneratedColumn<String>(
    'wind_direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherSourceMeta = const VerificationMeta(
    'weatherSource',
  );
  @override
  late final GeneratedColumn<String> weatherSource = GeneratedColumn<String>(
    'weather_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractionModelMeta = const VerificationMeta(
    'extractionModel',
  );
  @override
  late final GeneratedColumn<String> extractionModel = GeneratedColumn<String>(
    'extraction_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractionConfidenceMeta =
      const VerificationMeta('extractionConfidence');
  @override
  late final GeneratedColumn<double> extractionConfidence =
      GeneratedColumn<double>(
        'extraction_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rateFlagMeta = const VerificationMeta(
    'rateFlag',
  );
  @override
  late final GeneratedColumn<String> rateFlag = GeneratedColumn<String>(
    'rate_flag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overrideReasonMeta = const VerificationMeta(
    'overrideReason',
  );
  @override
  late final GeneratedColumn<String> overrideReason = GeneratedColumn<String>(
    'override_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signedAtMeta = const VerificationMeta(
    'signedAt',
  );
  @override
  late final GeneratedColumn<DateTime> signedAt = GeneratedColumn<DateTime>(
    'signed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signedByMeta = const VerificationMeta(
    'signedBy',
  );
  @override
  late final GeneratedColumn<String> signedBy = GeneratedColumn<String>(
    'signed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordHashMeta = const VerificationMeta(
    'recordHash',
  );
  @override
  late final GeneratedColumn<String> recordHash = GeneratedColumn<String>(
    'record_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prevHashMeta = const VerificationMeta(
    'prevHash',
  );
  @override
  late final GeneratedColumn<String> prevHash = GeneratedColumn<String>(
    'prev_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    applicatorId,
    customerId,
    siteId,
    state,
    appliedAt,
    productId,
    epaRegNo,
    brandName,
    rateValue,
    rateUnit,
    totalAmountValue,
    totalAmountUnit,
    areaValue,
    areaUnit,
    targetPest,
    applicationMethod,
    lat,
    lng,
    tempF,
    windMph,
    windDirection,
    weatherSource,
    transcript,
    extractionModel,
    extractionConfidence,
    rateFlag,
    overrideReason,
    signedAt,
    signedBy,
    recordHash,
    prevHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'applications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Application> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('applicator_id')) {
      context.handle(
        _applicatorIdMeta,
        applicatorId.isAcceptableOrUnknown(
          data['applicator_id']!,
          _applicatorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_applicatorIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('epa_reg_no')) {
      context.handle(
        _epaRegNoMeta,
        epaRegNo.isAcceptableOrUnknown(data['epa_reg_no']!, _epaRegNoMeta),
      );
    } else if (isInserting) {
      context.missing(_epaRegNoMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    } else if (isInserting) {
      context.missing(_brandNameMeta);
    }
    if (data.containsKey('rate_value')) {
      context.handle(
        _rateValueMeta,
        rateValue.isAcceptableOrUnknown(data['rate_value']!, _rateValueMeta),
      );
    } else if (isInserting) {
      context.missing(_rateValueMeta);
    }
    if (data.containsKey('rate_unit')) {
      context.handle(
        _rateUnitMeta,
        rateUnit.isAcceptableOrUnknown(data['rate_unit']!, _rateUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_rateUnitMeta);
    }
    if (data.containsKey('total_amount_value')) {
      context.handle(
        _totalAmountValueMeta,
        totalAmountValue.isAcceptableOrUnknown(
          data['total_amount_value']!,
          _totalAmountValueMeta,
        ),
      );
    }
    if (data.containsKey('total_amount_unit')) {
      context.handle(
        _totalAmountUnitMeta,
        totalAmountUnit.isAcceptableOrUnknown(
          data['total_amount_unit']!,
          _totalAmountUnitMeta,
        ),
      );
    }
    if (data.containsKey('area_value')) {
      context.handle(
        _areaValueMeta,
        areaValue.isAcceptableOrUnknown(data['area_value']!, _areaValueMeta),
      );
    } else if (isInserting) {
      context.missing(_areaValueMeta);
    }
    if (data.containsKey('area_unit')) {
      context.handle(
        _areaUnitMeta,
        areaUnit.isAcceptableOrUnknown(data['area_unit']!, _areaUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_areaUnitMeta);
    }
    if (data.containsKey('target_pest')) {
      context.handle(
        _targetPestMeta,
        targetPest.isAcceptableOrUnknown(data['target_pest']!, _targetPestMeta),
      );
    }
    if (data.containsKey('application_method')) {
      context.handle(
        _applicationMethodMeta,
        applicationMethod.isAcceptableOrUnknown(
          data['application_method']!,
          _applicationMethodMeta,
        ),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('temp_f')) {
      context.handle(
        _tempFMeta,
        tempF.isAcceptableOrUnknown(data['temp_f']!, _tempFMeta),
      );
    }
    if (data.containsKey('wind_mph')) {
      context.handle(
        _windMphMeta,
        windMph.isAcceptableOrUnknown(data['wind_mph']!, _windMphMeta),
      );
    }
    if (data.containsKey('wind_direction')) {
      context.handle(
        _windDirectionMeta,
        windDirection.isAcceptableOrUnknown(
          data['wind_direction']!,
          _windDirectionMeta,
        ),
      );
    }
    if (data.containsKey('weather_source')) {
      context.handle(
        _weatherSourceMeta,
        weatherSource.isAcceptableOrUnknown(
          data['weather_source']!,
          _weatherSourceMeta,
        ),
      );
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    if (data.containsKey('extraction_model')) {
      context.handle(
        _extractionModelMeta,
        extractionModel.isAcceptableOrUnknown(
          data['extraction_model']!,
          _extractionModelMeta,
        ),
      );
    }
    if (data.containsKey('extraction_confidence')) {
      context.handle(
        _extractionConfidenceMeta,
        extractionConfidence.isAcceptableOrUnknown(
          data['extraction_confidence']!,
          _extractionConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('rate_flag')) {
      context.handle(
        _rateFlagMeta,
        rateFlag.isAcceptableOrUnknown(data['rate_flag']!, _rateFlagMeta),
      );
    }
    if (data.containsKey('override_reason')) {
      context.handle(
        _overrideReasonMeta,
        overrideReason.isAcceptableOrUnknown(
          data['override_reason']!,
          _overrideReasonMeta,
        ),
      );
    }
    if (data.containsKey('signed_at')) {
      context.handle(
        _signedAtMeta,
        signedAt.isAcceptableOrUnknown(data['signed_at']!, _signedAtMeta),
      );
    }
    if (data.containsKey('signed_by')) {
      context.handle(
        _signedByMeta,
        signedBy.isAcceptableOrUnknown(data['signed_by']!, _signedByMeta),
      );
    }
    if (data.containsKey('record_hash')) {
      context.handle(
        _recordHashMeta,
        recordHash.isAcceptableOrUnknown(data['record_hash']!, _recordHashMeta),
      );
    }
    if (data.containsKey('prev_hash')) {
      context.handle(
        _prevHashMeta,
        prevHash.isAcceptableOrUnknown(data['prev_hash']!, _prevHashMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Application map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Application(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      applicatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applicator_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      epaRegNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epa_reg_no'],
      )!,
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      )!,
      rateValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate_value'],
      )!,
      rateUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_unit'],
      )!,
      totalAmountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount_value'],
      ),
      totalAmountUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_amount_unit'],
      ),
      areaValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_value'],
      )!,
      areaUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_unit'],
      )!,
      targetPest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_pest'],
      ),
      applicationMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}application_method'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      tempF: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temp_f'],
      ),
      windMph: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wind_mph'],
      ),
      windDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wind_direction'],
      ),
      weatherSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_source'],
      ),
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
      extractionModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extraction_model'],
      ),
      extractionConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}extraction_confidence'],
      ),
      rateFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_flag'],
      ),
      overrideReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_reason'],
      ),
      signedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}signed_at'],
      ),
      signedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signed_by'],
      ),
      recordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_hash'],
      ),
      prevHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prev_hash'],
      ),
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
  final String? customerId;
  final String? siteId;
  final String state;
  final DateTime appliedAt;
  final String productId;
  final String epaRegNo;
  final String brandName;
  final double rateValue;
  final String rateUnit;
  final double? totalAmountValue;
  final String? totalAmountUnit;
  final double areaValue;
  final String areaUnit;
  final String? targetPest;
  final String? applicationMethod;
  final double? lat;
  final double? lng;
  final double? tempF;
  final double? windMph;
  final String? windDirection;
  final String? weatherSource;
  final String? transcript;
  final String? extractionModel;
  final double? extractionConfidence;
  final String? rateFlag;
  final String? overrideReason;
  final DateTime? signedAt;
  final String? signedBy;
  final String? recordHash;
  final String? prevHash;
  const Application({
    required this.id,
    required this.companyId,
    required this.applicatorId,
    this.customerId,
    this.siteId,
    required this.state,
    required this.appliedAt,
    required this.productId,
    required this.epaRegNo,
    required this.brandName,
    required this.rateValue,
    required this.rateUnit,
    this.totalAmountValue,
    this.totalAmountUnit,
    required this.areaValue,
    required this.areaUnit,
    this.targetPest,
    this.applicationMethod,
    this.lat,
    this.lng,
    this.tempF,
    this.windMph,
    this.windDirection,
    this.weatherSource,
    this.transcript,
    this.extractionModel,
    this.extractionConfidence,
    this.rateFlag,
    this.overrideReason,
    this.signedAt,
    this.signedBy,
    this.recordHash,
    this.prevHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['applicator_id'] = Variable<String>(applicatorId);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || siteId != null) {
      map['site_id'] = Variable<String>(siteId);
    }
    map['state'] = Variable<String>(state);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    map['product_id'] = Variable<String>(productId);
    map['epa_reg_no'] = Variable<String>(epaRegNo);
    map['brand_name'] = Variable<String>(brandName);
    map['rate_value'] = Variable<double>(rateValue);
    map['rate_unit'] = Variable<String>(rateUnit);
    if (!nullToAbsent || totalAmountValue != null) {
      map['total_amount_value'] = Variable<double>(totalAmountValue);
    }
    if (!nullToAbsent || totalAmountUnit != null) {
      map['total_amount_unit'] = Variable<String>(totalAmountUnit);
    }
    map['area_value'] = Variable<double>(areaValue);
    map['area_unit'] = Variable<String>(areaUnit);
    if (!nullToAbsent || targetPest != null) {
      map['target_pest'] = Variable<String>(targetPest);
    }
    if (!nullToAbsent || applicationMethod != null) {
      map['application_method'] = Variable<String>(applicationMethod);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || tempF != null) {
      map['temp_f'] = Variable<double>(tempF);
    }
    if (!nullToAbsent || windMph != null) {
      map['wind_mph'] = Variable<double>(windMph);
    }
    if (!nullToAbsent || windDirection != null) {
      map['wind_direction'] = Variable<String>(windDirection);
    }
    if (!nullToAbsent || weatherSource != null) {
      map['weather_source'] = Variable<String>(weatherSource);
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    if (!nullToAbsent || extractionModel != null) {
      map['extraction_model'] = Variable<String>(extractionModel);
    }
    if (!nullToAbsent || extractionConfidence != null) {
      map['extraction_confidence'] = Variable<double>(extractionConfidence);
    }
    if (!nullToAbsent || rateFlag != null) {
      map['rate_flag'] = Variable<String>(rateFlag);
    }
    if (!nullToAbsent || overrideReason != null) {
      map['override_reason'] = Variable<String>(overrideReason);
    }
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
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      siteId: siteId == null && nullToAbsent
          ? const Value.absent()
          : Value(siteId),
      state: Value(state),
      appliedAt: Value(appliedAt),
      productId: Value(productId),
      epaRegNo: Value(epaRegNo),
      brandName: Value(brandName),
      rateValue: Value(rateValue),
      rateUnit: Value(rateUnit),
      totalAmountValue: totalAmountValue == null && nullToAbsent
          ? const Value.absent()
          : Value(totalAmountValue),
      totalAmountUnit: totalAmountUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(totalAmountUnit),
      areaValue: Value(areaValue),
      areaUnit: Value(areaUnit),
      targetPest: targetPest == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPest),
      applicationMethod: applicationMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(applicationMethod),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      tempF: tempF == null && nullToAbsent
          ? const Value.absent()
          : Value(tempF),
      windMph: windMph == null && nullToAbsent
          ? const Value.absent()
          : Value(windMph),
      windDirection: windDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(windDirection),
      weatherSource: weatherSource == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherSource),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      extractionModel: extractionModel == null && nullToAbsent
          ? const Value.absent()
          : Value(extractionModel),
      extractionConfidence: extractionConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(extractionConfidence),
      rateFlag: rateFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(rateFlag),
      overrideReason: overrideReason == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideReason),
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

  factory Application.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Application(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      applicatorId: serializer.fromJson<String>(json['applicatorId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      siteId: serializer.fromJson<String?>(json['siteId']),
      state: serializer.fromJson<String>(json['state']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
      productId: serializer.fromJson<String>(json['productId']),
      epaRegNo: serializer.fromJson<String>(json['epaRegNo']),
      brandName: serializer.fromJson<String>(json['brandName']),
      rateValue: serializer.fromJson<double>(json['rateValue']),
      rateUnit: serializer.fromJson<String>(json['rateUnit']),
      totalAmountValue: serializer.fromJson<double?>(json['totalAmountValue']),
      totalAmountUnit: serializer.fromJson<String?>(json['totalAmountUnit']),
      areaValue: serializer.fromJson<double>(json['areaValue']),
      areaUnit: serializer.fromJson<String>(json['areaUnit']),
      targetPest: serializer.fromJson<String?>(json['targetPest']),
      applicationMethod: serializer.fromJson<String?>(
        json['applicationMethod'],
      ),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      tempF: serializer.fromJson<double?>(json['tempF']),
      windMph: serializer.fromJson<double?>(json['windMph']),
      windDirection: serializer.fromJson<String?>(json['windDirection']),
      weatherSource: serializer.fromJson<String?>(json['weatherSource']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      extractionModel: serializer.fromJson<String?>(json['extractionModel']),
      extractionConfidence: serializer.fromJson<double?>(
        json['extractionConfidence'],
      ),
      rateFlag: serializer.fromJson<String?>(json['rateFlag']),
      overrideReason: serializer.fromJson<String?>(json['overrideReason']),
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
      'customerId': serializer.toJson<String?>(customerId),
      'siteId': serializer.toJson<String?>(siteId),
      'state': serializer.toJson<String>(state),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
      'productId': serializer.toJson<String>(productId),
      'epaRegNo': serializer.toJson<String>(epaRegNo),
      'brandName': serializer.toJson<String>(brandName),
      'rateValue': serializer.toJson<double>(rateValue),
      'rateUnit': serializer.toJson<String>(rateUnit),
      'totalAmountValue': serializer.toJson<double?>(totalAmountValue),
      'totalAmountUnit': serializer.toJson<String?>(totalAmountUnit),
      'areaValue': serializer.toJson<double>(areaValue),
      'areaUnit': serializer.toJson<String>(areaUnit),
      'targetPest': serializer.toJson<String?>(targetPest),
      'applicationMethod': serializer.toJson<String?>(applicationMethod),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'tempF': serializer.toJson<double?>(tempF),
      'windMph': serializer.toJson<double?>(windMph),
      'windDirection': serializer.toJson<String?>(windDirection),
      'weatherSource': serializer.toJson<String?>(weatherSource),
      'transcript': serializer.toJson<String?>(transcript),
      'extractionModel': serializer.toJson<String?>(extractionModel),
      'extractionConfidence': serializer.toJson<double?>(extractionConfidence),
      'rateFlag': serializer.toJson<String?>(rateFlag),
      'overrideReason': serializer.toJson<String?>(overrideReason),
      'signedAt': serializer.toJson<DateTime?>(signedAt),
      'signedBy': serializer.toJson<String?>(signedBy),
      'recordHash': serializer.toJson<String?>(recordHash),
      'prevHash': serializer.toJson<String?>(prevHash),
    };
  }

  Application copyWith({
    String? id,
    String? companyId,
    String? applicatorId,
    Value<String?> customerId = const Value.absent(),
    Value<String?> siteId = const Value.absent(),
    String? state,
    DateTime? appliedAt,
    String? productId,
    String? epaRegNo,
    String? brandName,
    double? rateValue,
    String? rateUnit,
    Value<double?> totalAmountValue = const Value.absent(),
    Value<String?> totalAmountUnit = const Value.absent(),
    double? areaValue,
    String? areaUnit,
    Value<String?> targetPest = const Value.absent(),
    Value<String?> applicationMethod = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> tempF = const Value.absent(),
    Value<double?> windMph = const Value.absent(),
    Value<String?> windDirection = const Value.absent(),
    Value<String?> weatherSource = const Value.absent(),
    Value<String?> transcript = const Value.absent(),
    Value<String?> extractionModel = const Value.absent(),
    Value<double?> extractionConfidence = const Value.absent(),
    Value<String?> rateFlag = const Value.absent(),
    Value<String?> overrideReason = const Value.absent(),
    Value<DateTime?> signedAt = const Value.absent(),
    Value<String?> signedBy = const Value.absent(),
    Value<String?> recordHash = const Value.absent(),
    Value<String?> prevHash = const Value.absent(),
  }) => Application(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    applicatorId: applicatorId ?? this.applicatorId,
    customerId: customerId.present ? customerId.value : this.customerId,
    siteId: siteId.present ? siteId.value : this.siteId,
    state: state ?? this.state,
    appliedAt: appliedAt ?? this.appliedAt,
    productId: productId ?? this.productId,
    epaRegNo: epaRegNo ?? this.epaRegNo,
    brandName: brandName ?? this.brandName,
    rateValue: rateValue ?? this.rateValue,
    rateUnit: rateUnit ?? this.rateUnit,
    totalAmountValue: totalAmountValue.present
        ? totalAmountValue.value
        : this.totalAmountValue,
    totalAmountUnit: totalAmountUnit.present
        ? totalAmountUnit.value
        : this.totalAmountUnit,
    areaValue: areaValue ?? this.areaValue,
    areaUnit: areaUnit ?? this.areaUnit,
    targetPest: targetPest.present ? targetPest.value : this.targetPest,
    applicationMethod: applicationMethod.present
        ? applicationMethod.value
        : this.applicationMethod,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    tempF: tempF.present ? tempF.value : this.tempF,
    windMph: windMph.present ? windMph.value : this.windMph,
    windDirection: windDirection.present
        ? windDirection.value
        : this.windDirection,
    weatherSource: weatherSource.present
        ? weatherSource.value
        : this.weatherSource,
    transcript: transcript.present ? transcript.value : this.transcript,
    extractionModel: extractionModel.present
        ? extractionModel.value
        : this.extractionModel,
    extractionConfidence: extractionConfidence.present
        ? extractionConfidence.value
        : this.extractionConfidence,
    rateFlag: rateFlag.present ? rateFlag.value : this.rateFlag,
    overrideReason: overrideReason.present
        ? overrideReason.value
        : this.overrideReason,
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
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      state: data.state.present ? data.state.value : this.state,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      productId: data.productId.present ? data.productId.value : this.productId,
      epaRegNo: data.epaRegNo.present ? data.epaRegNo.value : this.epaRegNo,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      rateValue: data.rateValue.present ? data.rateValue.value : this.rateValue,
      rateUnit: data.rateUnit.present ? data.rateUnit.value : this.rateUnit,
      totalAmountValue: data.totalAmountValue.present
          ? data.totalAmountValue.value
          : this.totalAmountValue,
      totalAmountUnit: data.totalAmountUnit.present
          ? data.totalAmountUnit.value
          : this.totalAmountUnit,
      areaValue: data.areaValue.present ? data.areaValue.value : this.areaValue,
      areaUnit: data.areaUnit.present ? data.areaUnit.value : this.areaUnit,
      targetPest: data.targetPest.present
          ? data.targetPest.value
          : this.targetPest,
      applicationMethod: data.applicationMethod.present
          ? data.applicationMethod.value
          : this.applicationMethod,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      tempF: data.tempF.present ? data.tempF.value : this.tempF,
      windMph: data.windMph.present ? data.windMph.value : this.windMph,
      windDirection: data.windDirection.present
          ? data.windDirection.value
          : this.windDirection,
      weatherSource: data.weatherSource.present
          ? data.weatherSource.value
          : this.weatherSource,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      extractionModel: data.extractionModel.present
          ? data.extractionModel.value
          : this.extractionModel,
      extractionConfidence: data.extractionConfidence.present
          ? data.extractionConfidence.value
          : this.extractionConfidence,
      rateFlag: data.rateFlag.present ? data.rateFlag.value : this.rateFlag,
      overrideReason: data.overrideReason.present
          ? data.overrideReason.value
          : this.overrideReason,
      signedAt: data.signedAt.present ? data.signedAt.value : this.signedAt,
      signedBy: data.signedBy.present ? data.signedBy.value : this.signedBy,
      recordHash: data.recordHash.present
          ? data.recordHash.value
          : this.recordHash,
      prevHash: data.prevHash.present ? data.prevHash.value : this.prevHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Application(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('applicatorId: $applicatorId, ')
          ..write('customerId: $customerId, ')
          ..write('siteId: $siteId, ')
          ..write('state: $state, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('productId: $productId, ')
          ..write('epaRegNo: $epaRegNo, ')
          ..write('brandName: $brandName, ')
          ..write('rateValue: $rateValue, ')
          ..write('rateUnit: $rateUnit, ')
          ..write('totalAmountValue: $totalAmountValue, ')
          ..write('totalAmountUnit: $totalAmountUnit, ')
          ..write('areaValue: $areaValue, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('targetPest: $targetPest, ')
          ..write('applicationMethod: $applicationMethod, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('tempF: $tempF, ')
          ..write('windMph: $windMph, ')
          ..write('windDirection: $windDirection, ')
          ..write('weatherSource: $weatherSource, ')
          ..write('transcript: $transcript, ')
          ..write('extractionModel: $extractionModel, ')
          ..write('extractionConfidence: $extractionConfidence, ')
          ..write('rateFlag: $rateFlag, ')
          ..write('overrideReason: $overrideReason, ')
          ..write('signedAt: $signedAt, ')
          ..write('signedBy: $signedBy, ')
          ..write('recordHash: $recordHash, ')
          ..write('prevHash: $prevHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    companyId,
    applicatorId,
    customerId,
    siteId,
    state,
    appliedAt,
    productId,
    epaRegNo,
    brandName,
    rateValue,
    rateUnit,
    totalAmountValue,
    totalAmountUnit,
    areaValue,
    areaUnit,
    targetPest,
    applicationMethod,
    lat,
    lng,
    tempF,
    windMph,
    windDirection,
    weatherSource,
    transcript,
    extractionModel,
    extractionConfidence,
    rateFlag,
    overrideReason,
    signedAt,
    signedBy,
    recordHash,
    prevHash,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Application &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.applicatorId == this.applicatorId &&
          other.customerId == this.customerId &&
          other.siteId == this.siteId &&
          other.state == this.state &&
          other.appliedAt == this.appliedAt &&
          other.productId == this.productId &&
          other.epaRegNo == this.epaRegNo &&
          other.brandName == this.brandName &&
          other.rateValue == this.rateValue &&
          other.rateUnit == this.rateUnit &&
          other.totalAmountValue == this.totalAmountValue &&
          other.totalAmountUnit == this.totalAmountUnit &&
          other.areaValue == this.areaValue &&
          other.areaUnit == this.areaUnit &&
          other.targetPest == this.targetPest &&
          other.applicationMethod == this.applicationMethod &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.tempF == this.tempF &&
          other.windMph == this.windMph &&
          other.windDirection == this.windDirection &&
          other.weatherSource == this.weatherSource &&
          other.transcript == this.transcript &&
          other.extractionModel == this.extractionModel &&
          other.extractionConfidence == this.extractionConfidence &&
          other.rateFlag == this.rateFlag &&
          other.overrideReason == this.overrideReason &&
          other.signedAt == this.signedAt &&
          other.signedBy == this.signedBy &&
          other.recordHash == this.recordHash &&
          other.prevHash == this.prevHash);
}

class ApplicationsCompanion extends UpdateCompanion<Application> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> applicatorId;
  final Value<String?> customerId;
  final Value<String?> siteId;
  final Value<String> state;
  final Value<DateTime> appliedAt;
  final Value<String> productId;
  final Value<String> epaRegNo;
  final Value<String> brandName;
  final Value<double> rateValue;
  final Value<String> rateUnit;
  final Value<double?> totalAmountValue;
  final Value<String?> totalAmountUnit;
  final Value<double> areaValue;
  final Value<String> areaUnit;
  final Value<String?> targetPest;
  final Value<String?> applicationMethod;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> tempF;
  final Value<double?> windMph;
  final Value<String?> windDirection;
  final Value<String?> weatherSource;
  final Value<String?> transcript;
  final Value<String?> extractionModel;
  final Value<double?> extractionConfidence;
  final Value<String?> rateFlag;
  final Value<String?> overrideReason;
  final Value<DateTime?> signedAt;
  final Value<String?> signedBy;
  final Value<String?> recordHash;
  final Value<String?> prevHash;
  final Value<int> rowid;
  const ApplicationsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.applicatorId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.siteId = const Value.absent(),
    this.state = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.productId = const Value.absent(),
    this.epaRegNo = const Value.absent(),
    this.brandName = const Value.absent(),
    this.rateValue = const Value.absent(),
    this.rateUnit = const Value.absent(),
    this.totalAmountValue = const Value.absent(),
    this.totalAmountUnit = const Value.absent(),
    this.areaValue = const Value.absent(),
    this.areaUnit = const Value.absent(),
    this.targetPest = const Value.absent(),
    this.applicationMethod = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.tempF = const Value.absent(),
    this.windMph = const Value.absent(),
    this.windDirection = const Value.absent(),
    this.weatherSource = const Value.absent(),
    this.transcript = const Value.absent(),
    this.extractionModel = const Value.absent(),
    this.extractionConfidence = const Value.absent(),
    this.rateFlag = const Value.absent(),
    this.overrideReason = const Value.absent(),
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
    this.customerId = const Value.absent(),
    this.siteId = const Value.absent(),
    required String state,
    required DateTime appliedAt,
    required String productId,
    required String epaRegNo,
    required String brandName,
    required double rateValue,
    required String rateUnit,
    this.totalAmountValue = const Value.absent(),
    this.totalAmountUnit = const Value.absent(),
    required double areaValue,
    required String areaUnit,
    this.targetPest = const Value.absent(),
    this.applicationMethod = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.tempF = const Value.absent(),
    this.windMph = const Value.absent(),
    this.windDirection = const Value.absent(),
    this.weatherSource = const Value.absent(),
    this.transcript = const Value.absent(),
    this.extractionModel = const Value.absent(),
    this.extractionConfidence = const Value.absent(),
    this.rateFlag = const Value.absent(),
    this.overrideReason = const Value.absent(),
    this.signedAt = const Value.absent(),
    this.signedBy = const Value.absent(),
    this.recordHash = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
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
    Expression<String>? customerId,
    Expression<String>? siteId,
    Expression<String>? state,
    Expression<DateTime>? appliedAt,
    Expression<String>? productId,
    Expression<String>? epaRegNo,
    Expression<String>? brandName,
    Expression<double>? rateValue,
    Expression<String>? rateUnit,
    Expression<double>? totalAmountValue,
    Expression<String>? totalAmountUnit,
    Expression<double>? areaValue,
    Expression<String>? areaUnit,
    Expression<String>? targetPest,
    Expression<String>? applicationMethod,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? tempF,
    Expression<double>? windMph,
    Expression<String>? windDirection,
    Expression<String>? weatherSource,
    Expression<String>? transcript,
    Expression<String>? extractionModel,
    Expression<double>? extractionConfidence,
    Expression<String>? rateFlag,
    Expression<String>? overrideReason,
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
      if (customerId != null) 'customer_id': customerId,
      if (siteId != null) 'site_id': siteId,
      if (state != null) 'state': state,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (productId != null) 'product_id': productId,
      if (epaRegNo != null) 'epa_reg_no': epaRegNo,
      if (brandName != null) 'brand_name': brandName,
      if (rateValue != null) 'rate_value': rateValue,
      if (rateUnit != null) 'rate_unit': rateUnit,
      if (totalAmountValue != null) 'total_amount_value': totalAmountValue,
      if (totalAmountUnit != null) 'total_amount_unit': totalAmountUnit,
      if (areaValue != null) 'area_value': areaValue,
      if (areaUnit != null) 'area_unit': areaUnit,
      if (targetPest != null) 'target_pest': targetPest,
      if (applicationMethod != null) 'application_method': applicationMethod,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (tempF != null) 'temp_f': tempF,
      if (windMph != null) 'wind_mph': windMph,
      if (windDirection != null) 'wind_direction': windDirection,
      if (weatherSource != null) 'weather_source': weatherSource,
      if (transcript != null) 'transcript': transcript,
      if (extractionModel != null) 'extraction_model': extractionModel,
      if (extractionConfidence != null)
        'extraction_confidence': extractionConfidence,
      if (rateFlag != null) 'rate_flag': rateFlag,
      if (overrideReason != null) 'override_reason': overrideReason,
      if (signedAt != null) 'signed_at': signedAt,
      if (signedBy != null) 'signed_by': signedBy,
      if (recordHash != null) 'record_hash': recordHash,
      if (prevHash != null) 'prev_hash': prevHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApplicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? applicatorId,
    Value<String?>? customerId,
    Value<String?>? siteId,
    Value<String>? state,
    Value<DateTime>? appliedAt,
    Value<String>? productId,
    Value<String>? epaRegNo,
    Value<String>? brandName,
    Value<double>? rateValue,
    Value<String>? rateUnit,
    Value<double?>? totalAmountValue,
    Value<String?>? totalAmountUnit,
    Value<double>? areaValue,
    Value<String>? areaUnit,
    Value<String?>? targetPest,
    Value<String?>? applicationMethod,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? tempF,
    Value<double?>? windMph,
    Value<String?>? windDirection,
    Value<String?>? weatherSource,
    Value<String?>? transcript,
    Value<String?>? extractionModel,
    Value<double?>? extractionConfidence,
    Value<String?>? rateFlag,
    Value<String?>? overrideReason,
    Value<DateTime?>? signedAt,
    Value<String?>? signedBy,
    Value<String?>? recordHash,
    Value<String?>? prevHash,
    Value<int>? rowid,
  }) {
    return ApplicationsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      applicatorId: applicatorId ?? this.applicatorId,
      customerId: customerId ?? this.customerId,
      siteId: siteId ?? this.siteId,
      state: state ?? this.state,
      appliedAt: appliedAt ?? this.appliedAt,
      productId: productId ?? this.productId,
      epaRegNo: epaRegNo ?? this.epaRegNo,
      brandName: brandName ?? this.brandName,
      rateValue: rateValue ?? this.rateValue,
      rateUnit: rateUnit ?? this.rateUnit,
      totalAmountValue: totalAmountValue ?? this.totalAmountValue,
      totalAmountUnit: totalAmountUnit ?? this.totalAmountUnit,
      areaValue: areaValue ?? this.areaValue,
      areaUnit: areaUnit ?? this.areaUnit,
      targetPest: targetPest ?? this.targetPest,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tempF: tempF ?? this.tempF,
      windMph: windMph ?? this.windMph,
      windDirection: windDirection ?? this.windDirection,
      weatherSource: weatherSource ?? this.weatherSource,
      transcript: transcript ?? this.transcript,
      extractionModel: extractionModel ?? this.extractionModel,
      extractionConfidence: extractionConfidence ?? this.extractionConfidence,
      rateFlag: rateFlag ?? this.rateFlag,
      overrideReason: overrideReason ?? this.overrideReason,
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
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
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
    if (totalAmountValue.present) {
      map['total_amount_value'] = Variable<double>(totalAmountValue.value);
    }
    if (totalAmountUnit.present) {
      map['total_amount_unit'] = Variable<String>(totalAmountUnit.value);
    }
    if (areaValue.present) {
      map['area_value'] = Variable<double>(areaValue.value);
    }
    if (areaUnit.present) {
      map['area_unit'] = Variable<String>(areaUnit.value);
    }
    if (targetPest.present) {
      map['target_pest'] = Variable<String>(targetPest.value);
    }
    if (applicationMethod.present) {
      map['application_method'] = Variable<String>(applicationMethod.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (tempF.present) {
      map['temp_f'] = Variable<double>(tempF.value);
    }
    if (windMph.present) {
      map['wind_mph'] = Variable<double>(windMph.value);
    }
    if (windDirection.present) {
      map['wind_direction'] = Variable<String>(windDirection.value);
    }
    if (weatherSource.present) {
      map['weather_source'] = Variable<String>(weatherSource.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (extractionModel.present) {
      map['extraction_model'] = Variable<String>(extractionModel.value);
    }
    if (extractionConfidence.present) {
      map['extraction_confidence'] = Variable<double>(
        extractionConfidence.value,
      );
    }
    if (rateFlag.present) {
      map['rate_flag'] = Variable<String>(rateFlag.value);
    }
    if (overrideReason.present) {
      map['override_reason'] = Variable<String>(overrideReason.value);
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
          ..write('customerId: $customerId, ')
          ..write('siteId: $siteId, ')
          ..write('state: $state, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('productId: $productId, ')
          ..write('epaRegNo: $epaRegNo, ')
          ..write('brandName: $brandName, ')
          ..write('rateValue: $rateValue, ')
          ..write('rateUnit: $rateUnit, ')
          ..write('totalAmountValue: $totalAmountValue, ')
          ..write('totalAmountUnit: $totalAmountUnit, ')
          ..write('areaValue: $areaValue, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('targetPest: $targetPest, ')
          ..write('applicationMethod: $applicationMethod, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('tempF: $tempF, ')
          ..write('windMph: $windMph, ')
          ..write('windDirection: $windDirection, ')
          ..write('weatherSource: $weatherSource, ')
          ..write('transcript: $transcript, ')
          ..write('extractionModel: $extractionModel, ')
          ..write('extractionConfidence: $extractionConfidence, ')
          ..write('rateFlag: $rateFlag, ')
          ..write('overrideReason: $overrideReason, ')
          ..write('signedAt: $signedAt, ')
          ..write('signedBy: $signedBy, ')
          ..write('recordHash: $recordHash, ')
          ..write('prevHash: $prevHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _epaRegNoMeta = const VerificationMeta(
    'epaRegNo',
  );
  @override
  late final GeneratedColumn<String> epaRegNo = GeneratedColumn<String>(
    'epa_reg_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandAliasesMeta = const VerificationMeta(
    'brandAliases',
  );
  @override
  late final GeneratedColumn<String> brandAliases = GeneratedColumn<String>(
    'brand_aliases',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signalWordMeta = const VerificationMeta(
    'signalWord',
  );
  @override
  late final GeneratedColumn<String> signalWord = GeneratedColumn<String>(
    'signal_word',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formulationMeta = const VerificationMeta(
    'formulation',
  );
  @override
  late final GeneratedColumn<String> formulation = GeneratedColumn<String>(
    'formulation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reiHoursMeta = const VerificationMeta(
    'reiHours',
  );
  @override
  late final GeneratedColumn<double> reiHours = GeneratedColumn<double>(
    'rei_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restrictedUseMeta = const VerificationMeta(
    'restrictedUse',
  );
  @override
  late final GeneratedColumn<bool> restrictedUse = GeneratedColumn<bool>(
    'restricted_use',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("restricted_use" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    epaRegNo,
    brandName,
    brandAliases,
    signalWord,
    formulation,
    reiHours,
    restrictedUse,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('epa_reg_no')) {
      context.handle(
        _epaRegNoMeta,
        epaRegNo.isAcceptableOrUnknown(data['epa_reg_no']!, _epaRegNoMeta),
      );
    } else if (isInserting) {
      context.missing(_epaRegNoMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    } else if (isInserting) {
      context.missing(_brandNameMeta);
    }
    if (data.containsKey('brand_aliases')) {
      context.handle(
        _brandAliasesMeta,
        brandAliases.isAcceptableOrUnknown(
          data['brand_aliases']!,
          _brandAliasesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_brandAliasesMeta);
    }
    if (data.containsKey('signal_word')) {
      context.handle(
        _signalWordMeta,
        signalWord.isAcceptableOrUnknown(data['signal_word']!, _signalWordMeta),
      );
    }
    if (data.containsKey('formulation')) {
      context.handle(
        _formulationMeta,
        formulation.isAcceptableOrUnknown(
          data['formulation']!,
          _formulationMeta,
        ),
      );
    }
    if (data.containsKey('rei_hours')) {
      context.handle(
        _reiHoursMeta,
        reiHours.isAcceptableOrUnknown(data['rei_hours']!, _reiHoursMeta),
      );
    }
    if (data.containsKey('restricted_use')) {
      context.handle(
        _restrictedUseMeta,
        restrictedUse.isAcceptableOrUnknown(
          data['restricted_use']!,
          _restrictedUseMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      epaRegNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epa_reg_no'],
      )!,
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      )!,
      brandAliases: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_aliases'],
      )!,
      signalWord: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signal_word'],
      ),
      formulation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formulation'],
      ),
      reiHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rei_hours'],
      ),
      restrictedUse: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}restricted_use'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String epaRegNo;
  final String brandName;

  /// JSON-encoded list of spoken/brand aliases.
  final String brandAliases;
  final String? signalWord;
  final String? formulation;
  final double? reiHours;
  final bool restrictedUse;
  final DateTime updatedAt;
  const Product({
    required this.id,
    required this.epaRegNo,
    required this.brandName,
    required this.brandAliases,
    this.signalWord,
    this.formulation,
    this.reiHours,
    required this.restrictedUse,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['epa_reg_no'] = Variable<String>(epaRegNo);
    map['brand_name'] = Variable<String>(brandName);
    map['brand_aliases'] = Variable<String>(brandAliases);
    if (!nullToAbsent || signalWord != null) {
      map['signal_word'] = Variable<String>(signalWord);
    }
    if (!nullToAbsent || formulation != null) {
      map['formulation'] = Variable<String>(formulation);
    }
    if (!nullToAbsent || reiHours != null) {
      map['rei_hours'] = Variable<double>(reiHours);
    }
    map['restricted_use'] = Variable<bool>(restrictedUse);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      epaRegNo: Value(epaRegNo),
      brandName: Value(brandName),
      brandAliases: Value(brandAliases),
      signalWord: signalWord == null && nullToAbsent
          ? const Value.absent()
          : Value(signalWord),
      formulation: formulation == null && nullToAbsent
          ? const Value.absent()
          : Value(formulation),
      reiHours: reiHours == null && nullToAbsent
          ? const Value.absent()
          : Value(reiHours),
      restrictedUse: Value(restrictedUse),
      updatedAt: Value(updatedAt),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      epaRegNo: serializer.fromJson<String>(json['epaRegNo']),
      brandName: serializer.fromJson<String>(json['brandName']),
      brandAliases: serializer.fromJson<String>(json['brandAliases']),
      signalWord: serializer.fromJson<String?>(json['signalWord']),
      formulation: serializer.fromJson<String?>(json['formulation']),
      reiHours: serializer.fromJson<double?>(json['reiHours']),
      restrictedUse: serializer.fromJson<bool>(json['restrictedUse']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'epaRegNo': serializer.toJson<String>(epaRegNo),
      'brandName': serializer.toJson<String>(brandName),
      'brandAliases': serializer.toJson<String>(brandAliases),
      'signalWord': serializer.toJson<String?>(signalWord),
      'formulation': serializer.toJson<String?>(formulation),
      'reiHours': serializer.toJson<double?>(reiHours),
      'restrictedUse': serializer.toJson<bool>(restrictedUse),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Product copyWith({
    String? id,
    String? epaRegNo,
    String? brandName,
    String? brandAliases,
    Value<String?> signalWord = const Value.absent(),
    Value<String?> formulation = const Value.absent(),
    Value<double?> reiHours = const Value.absent(),
    bool? restrictedUse,
    DateTime? updatedAt,
  }) => Product(
    id: id ?? this.id,
    epaRegNo: epaRegNo ?? this.epaRegNo,
    brandName: brandName ?? this.brandName,
    brandAliases: brandAliases ?? this.brandAliases,
    signalWord: signalWord.present ? signalWord.value : this.signalWord,
    formulation: formulation.present ? formulation.value : this.formulation,
    reiHours: reiHours.present ? reiHours.value : this.reiHours,
    restrictedUse: restrictedUse ?? this.restrictedUse,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      epaRegNo: data.epaRegNo.present ? data.epaRegNo.value : this.epaRegNo,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      brandAliases: data.brandAliases.present
          ? data.brandAliases.value
          : this.brandAliases,
      signalWord: data.signalWord.present
          ? data.signalWord.value
          : this.signalWord,
      formulation: data.formulation.present
          ? data.formulation.value
          : this.formulation,
      reiHours: data.reiHours.present ? data.reiHours.value : this.reiHours,
      restrictedUse: data.restrictedUse.present
          ? data.restrictedUse.value
          : this.restrictedUse,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('epaRegNo: $epaRegNo, ')
          ..write('brandName: $brandName, ')
          ..write('brandAliases: $brandAliases, ')
          ..write('signalWord: $signalWord, ')
          ..write('formulation: $formulation, ')
          ..write('reiHours: $reiHours, ')
          ..write('restrictedUse: $restrictedUse, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    epaRegNo,
    brandName,
    brandAliases,
    signalWord,
    formulation,
    reiHours,
    restrictedUse,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.epaRegNo == this.epaRegNo &&
          other.brandName == this.brandName &&
          other.brandAliases == this.brandAliases &&
          other.signalWord == this.signalWord &&
          other.formulation == this.formulation &&
          other.reiHours == this.reiHours &&
          other.restrictedUse == this.restrictedUse &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> epaRegNo;
  final Value<String> brandName;
  final Value<String> brandAliases;
  final Value<String?> signalWord;
  final Value<String?> formulation;
  final Value<double?> reiHours;
  final Value<bool> restrictedUse;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.epaRegNo = const Value.absent(),
    this.brandName = const Value.absent(),
    this.brandAliases = const Value.absent(),
    this.signalWord = const Value.absent(),
    this.formulation = const Value.absent(),
    this.reiHours = const Value.absent(),
    this.restrictedUse = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String epaRegNo,
    required String brandName,
    required String brandAliases,
    this.signalWord = const Value.absent(),
    this.formulation = const Value.absent(),
    this.reiHours = const Value.absent(),
    this.restrictedUse = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       epaRegNo = Value(epaRegNo),
       brandName = Value(brandName),
       brandAliases = Value(brandAliases),
       updatedAt = Value(updatedAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? epaRegNo,
    Expression<String>? brandName,
    Expression<String>? brandAliases,
    Expression<String>? signalWord,
    Expression<String>? formulation,
    Expression<double>? reiHours,
    Expression<bool>? restrictedUse,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (epaRegNo != null) 'epa_reg_no': epaRegNo,
      if (brandName != null) 'brand_name': brandName,
      if (brandAliases != null) 'brand_aliases': brandAliases,
      if (signalWord != null) 'signal_word': signalWord,
      if (formulation != null) 'formulation': formulation,
      if (reiHours != null) 'rei_hours': reiHours,
      if (restrictedUse != null) 'restricted_use': restrictedUse,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? epaRegNo,
    Value<String>? brandName,
    Value<String>? brandAliases,
    Value<String?>? signalWord,
    Value<String?>? formulation,
    Value<double?>? reiHours,
    Value<bool>? restrictedUse,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      epaRegNo: epaRegNo ?? this.epaRegNo,
      brandName: brandName ?? this.brandName,
      brandAliases: brandAliases ?? this.brandAliases,
      signalWord: signalWord ?? this.signalWord,
      formulation: formulation ?? this.formulation,
      reiHours: reiHours ?? this.reiHours,
      restrictedUse: restrictedUse ?? this.restrictedUse,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (epaRegNo.present) {
      map['epa_reg_no'] = Variable<String>(epaRegNo.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (brandAliases.present) {
      map['brand_aliases'] = Variable<String>(brandAliases.value);
    }
    if (signalWord.present) {
      map['signal_word'] = Variable<String>(signalWord.value);
    }
    if (formulation.present) {
      map['formulation'] = Variable<String>(formulation.value);
    }
    if (reiHours.present) {
      map['rei_hours'] = Variable<double>(reiHours.value);
    }
    if (restrictedUse.present) {
      map['restricted_use'] = Variable<bool>(restrictedUse.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('epaRegNo: $epaRegNo, ')
          ..write('brandName: $brandName, ')
          ..write('brandAliases: $brandAliases, ')
          ..write('signalWord: $signalWord, ')
          ..write('formulation: $formulation, ')
          ..write('reiHours: $reiHours, ')
          ..write('restrictedUse: $restrictedUse, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $ProductsTable products = $ProductsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    outboxItems,
    applications,
    products,
  ];
}

typedef $$OutboxItemsTableCreateCompanionBuilder =
    OutboxItemsCompanion Function({
      required String id,
      required String entity,
      required String operation,
      required String payload,
      Value<int> attempts,
      required DateTime nextAttemptAt,
      Value<int> rowid,
    });
typedef $$OutboxItemsTableUpdateCompanionBuilder =
    OutboxItemsCompanion Function({
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
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
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );
}

class $$OutboxItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxItemsTable,
          OutboxItem,
          $$OutboxItemsTableFilterComposer,
          $$OutboxItemsTableOrderingComposer,
          $$OutboxItemsTableAnnotationComposer,
          $$OutboxItemsTableCreateCompanionBuilder,
          $$OutboxItemsTableUpdateCompanionBuilder,
          (
            OutboxItem,
            BaseReferences<_$AppDatabase, $OutboxItemsTable, OutboxItem>,
          ),
          OutboxItem,
          PrefetchHooks Function()
        > {
  $$OutboxItemsTableTableManager(_$AppDatabase db, $OutboxItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> nextAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxItemsCompanion(
                id: id,
                entity: entity,
                operation: operation,
                payload: payload,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entity,
                required String operation,
                required String payload,
                Value<int> attempts = const Value.absent(),
                required DateTime nextAttemptAt,
                Value<int> rowid = const Value.absent(),
              }) => OutboxItemsCompanion.insert(
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
        ),
      );
}

typedef $$OutboxItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxItemsTable,
      OutboxItem,
      $$OutboxItemsTableFilterComposer,
      $$OutboxItemsTableOrderingComposer,
      $$OutboxItemsTableAnnotationComposer,
      $$OutboxItemsTableCreateCompanionBuilder,
      $$OutboxItemsTableUpdateCompanionBuilder,
      (
        OutboxItem,
        BaseReferences<_$AppDatabase, $OutboxItemsTable, OutboxItem>,
      ),
      OutboxItem,
      PrefetchHooks Function()
    >;
typedef $$ApplicationsTableCreateCompanionBuilder =
    ApplicationsCompanion Function({
      required String id,
      required String companyId,
      required String applicatorId,
      Value<String?> customerId,
      Value<String?> siteId,
      required String state,
      required DateTime appliedAt,
      required String productId,
      required String epaRegNo,
      required String brandName,
      required double rateValue,
      required String rateUnit,
      Value<double?> totalAmountValue,
      Value<String?> totalAmountUnit,
      required double areaValue,
      required String areaUnit,
      Value<String?> targetPest,
      Value<String?> applicationMethod,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> tempF,
      Value<double?> windMph,
      Value<String?> windDirection,
      Value<String?> weatherSource,
      Value<String?> transcript,
      Value<String?> extractionModel,
      Value<double?> extractionConfidence,
      Value<String?> rateFlag,
      Value<String?> overrideReason,
      Value<DateTime?> signedAt,
      Value<String?> signedBy,
      Value<String?> recordHash,
      Value<String?> prevHash,
      Value<int> rowid,
    });
typedef $$ApplicationsTableUpdateCompanionBuilder =
    ApplicationsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> applicatorId,
      Value<String?> customerId,
      Value<String?> siteId,
      Value<String> state,
      Value<DateTime> appliedAt,
      Value<String> productId,
      Value<String> epaRegNo,
      Value<String> brandName,
      Value<double> rateValue,
      Value<String> rateUnit,
      Value<double?> totalAmountValue,
      Value<String?> totalAmountUnit,
      Value<double> areaValue,
      Value<String> areaUnit,
      Value<String?> targetPest,
      Value<String?> applicationMethod,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> tempF,
      Value<double?> windMph,
      Value<String?> windDirection,
      Value<String?> weatherSource,
      Value<String?> transcript,
      Value<String?> extractionModel,
      Value<double?> extractionConfidence,
      Value<String?> rateFlag,
      Value<String?> overrideReason,
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get applicatorId => $composableBuilder(
    column: $table.applicatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epaRegNo => $composableBuilder(
    column: $table.epaRegNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rateValue => $composableBuilder(
    column: $table.rateValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rateUnit => $composableBuilder(
    column: $table.rateUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmountValue => $composableBuilder(
    column: $table.totalAmountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalAmountUnit => $composableBuilder(
    column: $table.totalAmountUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaValue => $composableBuilder(
    column: $table.areaValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaUnit => $composableBuilder(
    column: $table.areaUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetPest => $composableBuilder(
    column: $table.targetPest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get applicationMethod => $composableBuilder(
    column: $table.applicationMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempF => $composableBuilder(
    column: $table.tempF,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get windMph => $composableBuilder(
    column: $table.windMph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get windDirection => $composableBuilder(
    column: $table.windDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherSource => $composableBuilder(
    column: $table.weatherSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractionModel => $composableBuilder(
    column: $table.extractionModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get extractionConfidence => $composableBuilder(
    column: $table.extractionConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rateFlag => $composableBuilder(
    column: $table.rateFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overrideReason => $composableBuilder(
    column: $table.overrideReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get signedAt => $composableBuilder(
    column: $table.signedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signedBy => $composableBuilder(
    column: $table.signedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordHash => $composableBuilder(
    column: $table.recordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prevHash => $composableBuilder(
    column: $table.prevHash,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get applicatorId => $composableBuilder(
    column: $table.applicatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epaRegNo => $composableBuilder(
    column: $table.epaRegNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rateValue => $composableBuilder(
    column: $table.rateValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateUnit => $composableBuilder(
    column: $table.rateUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmountValue => $composableBuilder(
    column: $table.totalAmountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalAmountUnit => $composableBuilder(
    column: $table.totalAmountUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaValue => $composableBuilder(
    column: $table.areaValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaUnit => $composableBuilder(
    column: $table.areaUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetPest => $composableBuilder(
    column: $table.targetPest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get applicationMethod => $composableBuilder(
    column: $table.applicationMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempF => $composableBuilder(
    column: $table.tempF,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get windMph => $composableBuilder(
    column: $table.windMph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windDirection => $composableBuilder(
    column: $table.windDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherSource => $composableBuilder(
    column: $table.weatherSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractionModel => $composableBuilder(
    column: $table.extractionModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get extractionConfidence => $composableBuilder(
    column: $table.extractionConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateFlag => $composableBuilder(
    column: $table.rateFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overrideReason => $composableBuilder(
    column: $table.overrideReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get signedAt => $composableBuilder(
    column: $table.signedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signedBy => $composableBuilder(
    column: $table.signedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordHash => $composableBuilder(
    column: $table.recordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prevHash => $composableBuilder(
    column: $table.prevHash,
    builder: (column) => ColumnOrderings(column),
  );
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
    column: $table.applicatorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

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

  GeneratedColumn<double> get totalAmountValue => $composableBuilder(
    column: $table.totalAmountValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get totalAmountUnit => $composableBuilder(
    column: $table.totalAmountUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get areaValue =>
      $composableBuilder(column: $table.areaValue, builder: (column) => column);

  GeneratedColumn<String> get areaUnit =>
      $composableBuilder(column: $table.areaUnit, builder: (column) => column);

  GeneratedColumn<String> get targetPest => $composableBuilder(
    column: $table.targetPest,
    builder: (column) => column,
  );

  GeneratedColumn<String> get applicationMethod => $composableBuilder(
    column: $table.applicationMethod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get tempF =>
      $composableBuilder(column: $table.tempF, builder: (column) => column);

  GeneratedColumn<double> get windMph =>
      $composableBuilder(column: $table.windMph, builder: (column) => column);

  GeneratedColumn<String> get windDirection => $composableBuilder(
    column: $table.windDirection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weatherSource => $composableBuilder(
    column: $table.weatherSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extractionModel => $composableBuilder(
    column: $table.extractionModel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get extractionConfidence => $composableBuilder(
    column: $table.extractionConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rateFlag =>
      $composableBuilder(column: $table.rateFlag, builder: (column) => column);

  GeneratedColumn<String> get overrideReason => $composableBuilder(
    column: $table.overrideReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get signedAt =>
      $composableBuilder(column: $table.signedAt, builder: (column) => column);

  GeneratedColumn<String> get signedBy =>
      $composableBuilder(column: $table.signedBy, builder: (column) => column);

  GeneratedColumn<String> get recordHash => $composableBuilder(
    column: $table.recordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prevHash =>
      $composableBuilder(column: $table.prevHash, builder: (column) => column);
}

class $$ApplicationsTableTableManager
    extends
        RootTableManager<
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
            BaseReferences<_$AppDatabase, $ApplicationsTable, Application>,
          ),
          Application,
          PrefetchHooks Function()
        > {
  $$ApplicationsTableTableManager(_$AppDatabase db, $ApplicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApplicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApplicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApplicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> applicatorId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> siteId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> appliedAt = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> epaRegNo = const Value.absent(),
                Value<String> brandName = const Value.absent(),
                Value<double> rateValue = const Value.absent(),
                Value<String> rateUnit = const Value.absent(),
                Value<double?> totalAmountValue = const Value.absent(),
                Value<String?> totalAmountUnit = const Value.absent(),
                Value<double> areaValue = const Value.absent(),
                Value<String> areaUnit = const Value.absent(),
                Value<String?> targetPest = const Value.absent(),
                Value<String?> applicationMethod = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> tempF = const Value.absent(),
                Value<double?> windMph = const Value.absent(),
                Value<String?> windDirection = const Value.absent(),
                Value<String?> weatherSource = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<String?> extractionModel = const Value.absent(),
                Value<double?> extractionConfidence = const Value.absent(),
                Value<String?> rateFlag = const Value.absent(),
                Value<String?> overrideReason = const Value.absent(),
                Value<DateTime?> signedAt = const Value.absent(),
                Value<String?> signedBy = const Value.absent(),
                Value<String?> recordHash = const Value.absent(),
                Value<String?> prevHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApplicationsCompanion(
                id: id,
                companyId: companyId,
                applicatorId: applicatorId,
                customerId: customerId,
                siteId: siteId,
                state: state,
                appliedAt: appliedAt,
                productId: productId,
                epaRegNo: epaRegNo,
                brandName: brandName,
                rateValue: rateValue,
                rateUnit: rateUnit,
                totalAmountValue: totalAmountValue,
                totalAmountUnit: totalAmountUnit,
                areaValue: areaValue,
                areaUnit: areaUnit,
                targetPest: targetPest,
                applicationMethod: applicationMethod,
                lat: lat,
                lng: lng,
                tempF: tempF,
                windMph: windMph,
                windDirection: windDirection,
                weatherSource: weatherSource,
                transcript: transcript,
                extractionModel: extractionModel,
                extractionConfidence: extractionConfidence,
                rateFlag: rateFlag,
                overrideReason: overrideReason,
                signedAt: signedAt,
                signedBy: signedBy,
                recordHash: recordHash,
                prevHash: prevHash,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String applicatorId,
                Value<String?> customerId = const Value.absent(),
                Value<String?> siteId = const Value.absent(),
                required String state,
                required DateTime appliedAt,
                required String productId,
                required String epaRegNo,
                required String brandName,
                required double rateValue,
                required String rateUnit,
                Value<double?> totalAmountValue = const Value.absent(),
                Value<String?> totalAmountUnit = const Value.absent(),
                required double areaValue,
                required String areaUnit,
                Value<String?> targetPest = const Value.absent(),
                Value<String?> applicationMethod = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> tempF = const Value.absent(),
                Value<double?> windMph = const Value.absent(),
                Value<String?> windDirection = const Value.absent(),
                Value<String?> weatherSource = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<String?> extractionModel = const Value.absent(),
                Value<double?> extractionConfidence = const Value.absent(),
                Value<String?> rateFlag = const Value.absent(),
                Value<String?> overrideReason = const Value.absent(),
                Value<DateTime?> signedAt = const Value.absent(),
                Value<String?> signedBy = const Value.absent(),
                Value<String?> recordHash = const Value.absent(),
                Value<String?> prevHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApplicationsCompanion.insert(
                id: id,
                companyId: companyId,
                applicatorId: applicatorId,
                customerId: customerId,
                siteId: siteId,
                state: state,
                appliedAt: appliedAt,
                productId: productId,
                epaRegNo: epaRegNo,
                brandName: brandName,
                rateValue: rateValue,
                rateUnit: rateUnit,
                totalAmountValue: totalAmountValue,
                totalAmountUnit: totalAmountUnit,
                areaValue: areaValue,
                areaUnit: areaUnit,
                targetPest: targetPest,
                applicationMethod: applicationMethod,
                lat: lat,
                lng: lng,
                tempF: tempF,
                windMph: windMph,
                windDirection: windDirection,
                weatherSource: weatherSource,
                transcript: transcript,
                extractionModel: extractionModel,
                extractionConfidence: extractionConfidence,
                rateFlag: rateFlag,
                overrideReason: overrideReason,
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
        ),
      );
}

typedef $$ApplicationsTableProcessedTableManager =
    ProcessedTableManager<
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
        BaseReferences<_$AppDatabase, $ApplicationsTable, Application>,
      ),
      Application,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String epaRegNo,
      required String brandName,
      required String brandAliases,
      Value<String?> signalWord,
      Value<String?> formulation,
      Value<double?> reiHours,
      Value<bool> restrictedUse,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> epaRegNo,
      Value<String> brandName,
      Value<String> brandAliases,
      Value<String?> signalWord,
      Value<String?> formulation,
      Value<double?> reiHours,
      Value<bool> restrictedUse,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epaRegNo => $composableBuilder(
    column: $table.epaRegNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandAliases => $composableBuilder(
    column: $table.brandAliases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signalWord => $composableBuilder(
    column: $table.signalWord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formulation => $composableBuilder(
    column: $table.formulation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reiHours => $composableBuilder(
    column: $table.reiHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get restrictedUse => $composableBuilder(
    column: $table.restrictedUse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epaRegNo => $composableBuilder(
    column: $table.epaRegNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandAliases => $composableBuilder(
    column: $table.brandAliases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signalWord => $composableBuilder(
    column: $table.signalWord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formulation => $composableBuilder(
    column: $table.formulation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reiHours => $composableBuilder(
    column: $table.reiHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get restrictedUse => $composableBuilder(
    column: $table.restrictedUse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get epaRegNo =>
      $composableBuilder(column: $table.epaRegNo, builder: (column) => column);

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<String> get brandAliases => $composableBuilder(
    column: $table.brandAliases,
    builder: (column) => column,
  );

  GeneratedColumn<String> get signalWord => $composableBuilder(
    column: $table.signalWord,
    builder: (column) => column,
  );

  GeneratedColumn<String> get formulation => $composableBuilder(
    column: $table.formulation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get reiHours =>
      $composableBuilder(column: $table.reiHours, builder: (column) => column);

  GeneratedColumn<bool> get restrictedUse => $composableBuilder(
    column: $table.restrictedUse,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
          Product,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> epaRegNo = const Value.absent(),
                Value<String> brandName = const Value.absent(),
                Value<String> brandAliases = const Value.absent(),
                Value<String?> signalWord = const Value.absent(),
                Value<String?> formulation = const Value.absent(),
                Value<double?> reiHours = const Value.absent(),
                Value<bool> restrictedUse = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                epaRegNo: epaRegNo,
                brandName: brandName,
                brandAliases: brandAliases,
                signalWord: signalWord,
                formulation: formulation,
                reiHours: reiHours,
                restrictedUse: restrictedUse,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String epaRegNo,
                required String brandName,
                required String brandAliases,
                Value<String?> signalWord = const Value.absent(),
                Value<String?> formulation = const Value.absent(),
                Value<double?> reiHours = const Value.absent(),
                Value<bool> restrictedUse = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                epaRegNo: epaRegNo,
                brandName: brandName,
                brandAliases: brandAliases,
                signalWord: signalWord,
                formulation: formulation,
                reiHours: reiHours,
                restrictedUse: restrictedUse,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
      Product,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxItemsTableTableManager get outboxItems =>
      $$OutboxItemsTableTableManager(_db, _db.outboxItems);
  $$ApplicationsTableTableManager get applications =>
      $$ApplicationsTableTableManager(_db, _db.applications);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
}
