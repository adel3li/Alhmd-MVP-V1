// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _blessingIdMeta = const VerificationMeta(
    'blessingId',
  );
  @override
  late final GeneratedColumn<String> blessingId = GeneratedColumn<String>(
    'blessing_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blessingTitleMeta = const VerificationMeta(
    'blessingTitle',
  );
  @override
  late final GeneratedColumn<String> blessingTitle = GeneratedColumn<String>(
    'blessing_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    blessingId,
    blessingTitle,
    body,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('blessing_id')) {
      context.handle(
        _blessingIdMeta,
        blessingId.isAcceptableOrUnknown(data['blessing_id']!, _blessingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_blessingIdMeta);
    }
    if (data.containsKey('blessing_title')) {
      context.handle(
        _blessingTitleMeta,
        blessingTitle.isAcceptableOrUnknown(
          data['blessing_title']!,
          _blessingTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_blessingTitleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      blessingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blessing_id'],
      )!,
      blessingTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blessing_title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntryRow extends DataClass implements Insertable<JournalEntryRow> {
  final int id;
  final String blessingId;
  final String blessingTitle;
  final String body;
  final DateTime createdAt;
  const JournalEntryRow({
    required this.id,
    required this.blessingId,
    required this.blessingTitle,
    required this.body,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['blessing_id'] = Variable<String>(blessingId);
    map['blessing_title'] = Variable<String>(blessingTitle);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      blessingId: Value(blessingId),
      blessingTitle: Value(blessingTitle),
      body: Value(body),
      createdAt: Value(createdAt),
    );
  }

  factory JournalEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntryRow(
      id: serializer.fromJson<int>(json['id']),
      blessingId: serializer.fromJson<String>(json['blessingId']),
      blessingTitle: serializer.fromJson<String>(json['blessingTitle']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'blessingId': serializer.toJson<String>(blessingId),
      'blessingTitle': serializer.toJson<String>(blessingTitle),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  JournalEntryRow copyWith({
    int? id,
    String? blessingId,
    String? blessingTitle,
    String? body,
    DateTime? createdAt,
  }) => JournalEntryRow(
    id: id ?? this.id,
    blessingId: blessingId ?? this.blessingId,
    blessingTitle: blessingTitle ?? this.blessingTitle,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
  );
  JournalEntryRow copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntryRow(
      id: data.id.present ? data.id.value : this.id,
      blessingId: data.blessingId.present
          ? data.blessingId.value
          : this.blessingId,
      blessingTitle: data.blessingTitle.present
          ? data.blessingTitle.value
          : this.blessingTitle,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntryRow(')
          ..write('id: $id, ')
          ..write('blessingId: $blessingId, ')
          ..write('blessingTitle: $blessingTitle, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, blessingId, blessingTitle, body, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntryRow &&
          other.id == this.id &&
          other.blessingId == this.blessingId &&
          other.blessingTitle == this.blessingTitle &&
          other.body == this.body &&
          other.createdAt == this.createdAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntryRow> {
  final Value<int> id;
  final Value<String> blessingId;
  final Value<String> blessingTitle;
  final Value<String> body;
  final Value<DateTime> createdAt;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.blessingId = const Value.absent(),
    this.blessingTitle = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String blessingId,
    required String blessingTitle,
    required String body,
    required DateTime createdAt,
  }) : blessingId = Value(blessingId),
       blessingTitle = Value(blessingTitle),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<JournalEntryRow> custom({
    Expression<int>? id,
    Expression<String>? blessingId,
    Expression<String>? blessingTitle,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (blessingId != null) 'blessing_id': blessingId,
      if (blessingTitle != null) 'blessing_title': blessingTitle,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? blessingId,
    Value<String>? blessingTitle,
    Value<String>? body,
    Value<DateTime>? createdAt,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      blessingId: blessingId ?? this.blessingId,
      blessingTitle: blessingTitle ?? this.blessingTitle,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (blessingId.present) {
      map['blessing_id'] = Variable<String>(blessingId.value);
    }
    if (blessingTitle.present) {
      map['blessing_title'] = Variable<String>(blessingTitle.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('blessingId: $blessingId, ')
          ..write('blessingTitle: $blessingTitle, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CompletionsTable extends Completions
    with TableInfo<$CompletionsTable, CompletionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blessingIdMeta = const VerificationMeta(
    'blessingId',
  );
  @override
  late final GeneratedColumn<String> blessingId = GeneratedColumn<String>(
    'blessing_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    dayKey,
    blessingId,
    completedAt,
    durationSec,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('blessing_id')) {
      context.handle(
        _blessingIdMeta,
        blessingId.isAcceptableOrUnknown(data['blessing_id']!, _blessingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_blessingIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayKey};
  @override
  CompletionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionRow(
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      blessingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blessing_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      ),
    );
  }

  @override
  $CompletionsTable createAlias(String alias) {
    return $CompletionsTable(attachedDatabase, alias);
  }
}

class CompletionRow extends DataClass implements Insertable<CompletionRow> {
  /// Local-date key 'yyyy-MM-dd' — one completion per day (re-reflections
  /// update the row instead of inserting).
  final String dayKey;
  final String blessingId;
  final DateTime completedAt;
  final int? durationSec;
  const CompletionRow({
    required this.dayKey,
    required this.blessingId,
    required this.completedAt,
    this.durationSec,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_key'] = Variable<String>(dayKey);
    map['blessing_id'] = Variable<String>(blessingId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || durationSec != null) {
      map['duration_sec'] = Variable<int>(durationSec);
    }
    return map;
  }

  CompletionsCompanion toCompanion(bool nullToAbsent) {
    return CompletionsCompanion(
      dayKey: Value(dayKey),
      blessingId: Value(blessingId),
      completedAt: Value(completedAt),
      durationSec: durationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSec),
    );
  }

  factory CompletionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionRow(
      dayKey: serializer.fromJson<String>(json['dayKey']),
      blessingId: serializer.fromJson<String>(json['blessingId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      durationSec: serializer.fromJson<int?>(json['durationSec']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayKey': serializer.toJson<String>(dayKey),
      'blessingId': serializer.toJson<String>(blessingId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'durationSec': serializer.toJson<int?>(durationSec),
    };
  }

  CompletionRow copyWith({
    String? dayKey,
    String? blessingId,
    DateTime? completedAt,
    Value<int?> durationSec = const Value.absent(),
  }) => CompletionRow(
    dayKey: dayKey ?? this.dayKey,
    blessingId: blessingId ?? this.blessingId,
    completedAt: completedAt ?? this.completedAt,
    durationSec: durationSec.present ? durationSec.value : this.durationSec,
  );
  CompletionRow copyWithCompanion(CompletionsCompanion data) {
    return CompletionRow(
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      blessingId: data.blessingId.present
          ? data.blessingId.value
          : this.blessingId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionRow(')
          ..write('dayKey: $dayKey, ')
          ..write('blessingId: $blessingId, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationSec: $durationSec')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayKey, blessingId, completedAt, durationSec);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionRow &&
          other.dayKey == this.dayKey &&
          other.blessingId == this.blessingId &&
          other.completedAt == this.completedAt &&
          other.durationSec == this.durationSec);
}

class CompletionsCompanion extends UpdateCompanion<CompletionRow> {
  final Value<String> dayKey;
  final Value<String> blessingId;
  final Value<DateTime> completedAt;
  final Value<int?> durationSec;
  final Value<int> rowid;
  const CompletionsCompanion({
    this.dayKey = const Value.absent(),
    this.blessingId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionsCompanion.insert({
    required String dayKey,
    required String blessingId,
    required DateTime completedAt,
    this.durationSec = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dayKey = Value(dayKey),
       blessingId = Value(blessingId),
       completedAt = Value(completedAt);
  static Insertable<CompletionRow> custom({
    Expression<String>? dayKey,
    Expression<String>? blessingId,
    Expression<DateTime>? completedAt,
    Expression<int>? durationSec,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayKey != null) 'day_key': dayKey,
      if (blessingId != null) 'blessing_id': blessingId,
      if (completedAt != null) 'completed_at': completedAt,
      if (durationSec != null) 'duration_sec': durationSec,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionsCompanion copyWith({
    Value<String>? dayKey,
    Value<String>? blessingId,
    Value<DateTime>? completedAt,
    Value<int?>? durationSec,
    Value<int>? rowid,
  }) {
    return CompletionsCompanion(
      dayKey: dayKey ?? this.dayKey,
      blessingId: blessingId ?? this.blessingId,
      completedAt: completedAt ?? this.completedAt,
      durationSec: durationSec ?? this.durationSec,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (blessingId.present) {
      map['blessing_id'] = Variable<String>(blessingId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsCompanion(')
          ..write('dayKey: $dayKey, ')
          ..write('blessingId: $blessingId, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationSec: $durationSec, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $CompletionsTable completions = $CompletionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    journalEntries,
    completions,
  ];
}

typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      required String blessingId,
      required String blessingTitle,
      required String body,
      required DateTime createdAt,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      Value<String> blessingId,
      Value<String> blessingTitle,
      Value<String> body,
      Value<DateTime> createdAt,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blessingId => $composableBuilder(
    column: $table.blessingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blessingTitle => $composableBuilder(
    column: $table.blessingTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blessingId => $composableBuilder(
    column: $table.blessingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blessingTitle => $composableBuilder(
    column: $table.blessingTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get blessingId => $composableBuilder(
    column: $table.blessingId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get blessingTitle => $composableBuilder(
    column: $table.blessingTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntryRow,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntryRow,
            BaseReferences<
              _$AppDatabase,
              $JournalEntriesTable,
              JournalEntryRow
            >,
          ),
          JournalEntryRow,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> blessingId = const Value.absent(),
                Value<String> blessingTitle = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                blessingId: blessingId,
                blessingTitle: blessingTitle,
                body: body,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String blessingId,
                required String blessingTitle,
                required String body,
                required DateTime createdAt,
              }) => JournalEntriesCompanion.insert(
                id: id,
                blessingId: blessingId,
                blessingTitle: blessingTitle,
                body: body,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntryRow,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntryRow,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntryRow>,
      ),
      JournalEntryRow,
      PrefetchHooks Function()
    >;
typedef $$CompletionsTableCreateCompanionBuilder =
    CompletionsCompanion Function({
      required String dayKey,
      required String blessingId,
      required DateTime completedAt,
      Value<int?> durationSec,
      Value<int> rowid,
    });
typedef $$CompletionsTableUpdateCompanionBuilder =
    CompletionsCompanion Function({
      Value<String> dayKey,
      Value<String> blessingId,
      Value<DateTime> completedAt,
      Value<int?> durationSec,
      Value<int> rowid,
    });

class $$CompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blessingId => $composableBuilder(
    column: $table.blessingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blessingId => $composableBuilder(
    column: $table.blessingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<String> get blessingId => $composableBuilder(
    column: $table.blessingId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );
}

class $$CompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionsTable,
          CompletionRow,
          $$CompletionsTableFilterComposer,
          $$CompletionsTableOrderingComposer,
          $$CompletionsTableAnnotationComposer,
          $$CompletionsTableCreateCompanionBuilder,
          $$CompletionsTableUpdateCompanionBuilder,
          (
            CompletionRow,
            BaseReferences<_$AppDatabase, $CompletionsTable, CompletionRow>,
          ),
          CompletionRow,
          PrefetchHooks Function()
        > {
  $$CompletionsTableTableManager(_$AppDatabase db, $CompletionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dayKey = const Value.absent(),
                Value<String> blessingId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion(
                dayKey: dayKey,
                blessingId: blessingId,
                completedAt: completedAt,
                durationSec: durationSec,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dayKey,
                required String blessingId,
                required DateTime completedAt,
                Value<int?> durationSec = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion.insert(
                dayKey: dayKey,
                blessingId: blessingId,
                completedAt: completedAt,
                durationSec: durationSec,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionsTable,
      CompletionRow,
      $$CompletionsTableFilterComposer,
      $$CompletionsTableOrderingComposer,
      $$CompletionsTableAnnotationComposer,
      $$CompletionsTableCreateCompanionBuilder,
      $$CompletionsTableUpdateCompanionBuilder,
      (
        CompletionRow,
        BaseReferences<_$AppDatabase, $CompletionsTable, CompletionRow>,
      ),
      CompletionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$CompletionsTableTableManager get completions =>
      $$CompletionsTableTableManager(_db, _db.completions);
}
