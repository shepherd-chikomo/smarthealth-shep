// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FacilitiesTable extends Facilities
    with TableInfo<$FacilitiesTable, Facility> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.synced),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    name,
    city,
    address,
    latitude,
    longitude,
    logoUrl,
    syncStatus,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facilities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Facility> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Facility map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Facility(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $FacilitiesTable createAlias(String alias) {
    return $FacilitiesTable(attachedDatabase, alias);
  }
}

class Facility extends DataClass implements Insertable<Facility> {
  final String id;
  final String? serverId;
  final String name;
  final String? city;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final String syncStatus;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Facility({
    required this.id,
    this.serverId,
    required this.name,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.logoUrl,
    required this.syncStatus,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  FacilitiesCompanion toCompanion(bool nullToAbsent) {
    return FacilitiesCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      name: Value(name),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Facility.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Facility(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      city: serializer.fromJson<String?>(json['city']),
      address: serializer.fromJson<String?>(json['address']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'name': serializer.toJson<String>(name),
      'city': serializer.toJson<String?>(city),
      'address': serializer.toJson<String?>(address),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Facility copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? name,
    Value<String?> city = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> logoUrl = const Value.absent(),
    String? syncStatus,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Facility(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    name: name ?? this.name,
    city: city.present ? city.value : this.city,
    address: address.present ? address.value : this.address,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Facility copyWithCompanion(FacilitiesCompanion data) {
    return Facility(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      city: data.city.present ? data.city.value : this.city,
      address: data.address.present ? data.address.value : this.address,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Facility(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    name,
    city,
    address,
    latitude,
    longitude,
    logoUrl,
    syncStatus,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Facility &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.city == this.city &&
          other.address == this.address &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.logoUrl == this.logoUrl &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class FacilitiesCompanion extends UpdateCompanion<Facility> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> name;
  final Value<String?> city;
  final Value<String?> address;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> logoUrl;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const FacilitiesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.city = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacilitiesCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String name,
    this.city = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<Facility> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? name,
    Expression<String>? city,
    Expression<String>? address,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? logoUrl,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (city != null) 'city': city,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacilitiesCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? name,
    Value<String?>? city,
    Value<String?>? address,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? logoUrl,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return FacilitiesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoUrl: logoUrl ?? this.logoUrl,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FacilitiesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FacilityMembershipsTable extends FacilityMemberships
    with TableInfo<$FacilityMembershipsTable, FacilityMembership> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacilityMembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facilities (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.synced),
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
    facilityId,
    userId,
    role,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facility_memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<FacilityMembership> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  FacilityMembership map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FacilityMembership(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FacilityMembershipsTable createAlias(String alias) {
    return $FacilityMembershipsTable(attachedDatabase, alias);
  }
}

class FacilityMembership extends DataClass
    implements Insertable<FacilityMembership> {
  final String id;
  final String facilityId;
  final String userId;
  final String role;
  final String syncStatus;
  final DateTime updatedAt;
  const FacilityMembership({
    required this.id,
    required this.facilityId,
    required this.userId,
    required this.role,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['facility_id'] = Variable<String>(facilityId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FacilityMembershipsCompanion toCompanion(bool nullToAbsent) {
    return FacilityMembershipsCompanion(
      id: Value(id),
      facilityId: Value(facilityId),
      userId: Value(userId),
      role: Value(role),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory FacilityMembership.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FacilityMembership(
      id: serializer.fromJson<String>(json['id']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'facilityId': serializer.toJson<String>(facilityId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FacilityMembership copyWith({
    String? id,
    String? facilityId,
    String? userId,
    String? role,
    String? syncStatus,
    DateTime? updatedAt,
  }) => FacilityMembership(
    id: id ?? this.id,
    facilityId: facilityId ?? this.facilityId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FacilityMembership copyWithCompanion(FacilityMembershipsCompanion data) {
    return FacilityMembership(
      id: data.id.present ? data.id.value : this.id,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FacilityMembership(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, facilityId, userId, role, syncStatus, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FacilityMembership &&
          other.id == this.id &&
          other.facilityId == this.facilityId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class FacilityMembershipsCompanion extends UpdateCompanion<FacilityMembership> {
  final Value<String> id;
  final Value<String> facilityId;
  final Value<String> userId;
  final Value<String> role;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FacilityMembershipsCompanion({
    this.id = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacilityMembershipsCompanion.insert({
    required String id,
    required String facilityId,
    required String userId,
    required String role,
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityId = Value(facilityId),
       userId = Value(userId),
       role = Value(role),
       updatedAt = Value(updatedAt);
  static Insertable<FacilityMembership> custom({
    Expression<String>? id,
    Expression<String>? facilityId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (facilityId != null) 'facility_id': facilityId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacilityMembershipsCompanion copyWith({
    Value<String>? id,
    Value<String>? facilityId,
    Value<String>? userId,
    Value<String>? role,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FacilityMembershipsCompanion(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('FacilityMembershipsCompanion(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PractitionersTable extends Practitioners
    with TableInfo<$PractitionersTable, Practitioner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PractitionersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facilities (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specialtyMeta = const VerificationMeta(
    'specialty',
  );
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
    'specialty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registrationNumberMeta =
      const VerificationMeta('registrationNumber');
  @override
  late final GeneratedColumn<String> registrationNumber =
      GeneratedColumn<String>(
        'registration_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.synced),
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
    serverId,
    facilityId,
    name,
    specialty,
    registrationNumber,
    role,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practitioners';
  @override
  VerificationContext validateIntegrity(
    Insertable<Practitioner> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('specialty')) {
      context.handle(
        _specialtyMeta,
        specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta),
      );
    }
    if (data.containsKey('registration_number')) {
      context.handle(
        _registrationNumberMeta,
        registrationNumber.isAcceptableOrUnknown(
          data['registration_number']!,
          _registrationNumberMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  Practitioner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Practitioner(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      specialty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialty'],
      ),
      registrationNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_number'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PractitionersTable createAlias(String alias) {
    return $PractitionersTable(attachedDatabase, alias);
  }
}

class Practitioner extends DataClass implements Insertable<Practitioner> {
  final String id;
  final String? serverId;
  final String facilityId;
  final String name;
  final String? specialty;
  final String? registrationNumber;
  final String? role;
  final String syncStatus;
  final DateTime updatedAt;
  const Practitioner({
    required this.id,
    this.serverId,
    required this.facilityId,
    required this.name,
    this.specialty,
    this.registrationNumber,
    this.role,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['facility_id'] = Variable<String>(facilityId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || specialty != null) {
      map['specialty'] = Variable<String>(specialty);
    }
    if (!nullToAbsent || registrationNumber != null) {
      map['registration_number'] = Variable<String>(registrationNumber);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PractitionersCompanion toCompanion(bool nullToAbsent) {
    return PractitionersCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      facilityId: Value(facilityId),
      name: Value(name),
      specialty: specialty == null && nullToAbsent
          ? const Value.absent()
          : Value(specialty),
      registrationNumber: registrationNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationNumber),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory Practitioner.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Practitioner(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      name: serializer.fromJson<String>(json['name']),
      specialty: serializer.fromJson<String?>(json['specialty']),
      registrationNumber: serializer.fromJson<String?>(
        json['registrationNumber'],
      ),
      role: serializer.fromJson<String?>(json['role']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'facilityId': serializer.toJson<String>(facilityId),
      'name': serializer.toJson<String>(name),
      'specialty': serializer.toJson<String?>(specialty),
      'registrationNumber': serializer.toJson<String?>(registrationNumber),
      'role': serializer.toJson<String?>(role),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Practitioner copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? facilityId,
    String? name,
    Value<String?> specialty = const Value.absent(),
    Value<String?> registrationNumber = const Value.absent(),
    Value<String?> role = const Value.absent(),
    String? syncStatus,
    DateTime? updatedAt,
  }) => Practitioner(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    facilityId: facilityId ?? this.facilityId,
    name: name ?? this.name,
    specialty: specialty.present ? specialty.value : this.specialty,
    registrationNumber: registrationNumber.present
        ? registrationNumber.value
        : this.registrationNumber,
    role: role.present ? role.value : this.role,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Practitioner copyWithCompanion(PractitionersCompanion data) {
    return Practitioner(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      name: data.name.present ? data.name.value : this.name,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      registrationNumber: data.registrationNumber.present
          ? data.registrationNumber.value
          : this.registrationNumber,
      role: data.role.present ? data.role.value : this.role,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Practitioner(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('facilityId: $facilityId, ')
          ..write('name: $name, ')
          ..write('specialty: $specialty, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('role: $role, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    facilityId,
    name,
    specialty,
    registrationNumber,
    role,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Practitioner &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.facilityId == this.facilityId &&
          other.name == this.name &&
          other.specialty == this.specialty &&
          other.registrationNumber == this.registrationNumber &&
          other.role == this.role &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class PractitionersCompanion extends UpdateCompanion<Practitioner> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> facilityId;
  final Value<String> name;
  final Value<String?> specialty;
  final Value<String?> registrationNumber;
  final Value<String?> role;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PractitionersCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.name = const Value.absent(),
    this.specialty = const Value.absent(),
    this.registrationNumber = const Value.absent(),
    this.role = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PractitionersCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String facilityId,
    required String name,
    this.specialty = const Value.absent(),
    this.registrationNumber = const Value.absent(),
    this.role = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityId = Value(facilityId),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<Practitioner> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? facilityId,
    Expression<String>? name,
    Expression<String>? specialty,
    Expression<String>? registrationNumber,
    Expression<String>? role,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (facilityId != null) 'facility_id': facilityId,
      if (name != null) 'name': name,
      if (specialty != null) 'specialty': specialty,
      if (registrationNumber != null) 'registration_number': registrationNumber,
      if (role != null) 'role': role,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PractitionersCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? facilityId,
    Value<String>? name,
    Value<String?>? specialty,
    Value<String?>? registrationNumber,
    Value<String?>? role,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PractitionersCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      facilityId: facilityId ?? this.facilityId,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      role: role ?? this.role,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (registrationNumber.present) {
      map['registration_number'] = Variable<String>(registrationNumber.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('PractitionersCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('facilityId: $facilityId, ')
          ..write('name: $name, ')
          ..write('specialty: $specialty, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('role: $role, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _smarthealthPatientIdMeta =
      const VerificationMeta('smarthealthPatientId');
  @override
  late final GeneratedColumn<String> smarthealthPatientId =
      GeneratedColumn<String>(
        'smarthealth_patient_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'national_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passportMeta = const VerificationMeta(
    'passport',
  );
  @override
  late final GeneratedColumn<String> passport = GeneratedColumn<String>(
    'passport',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _insuranceInfoMeta = const VerificationMeta(
    'insuranceInfo',
  );
  @override
  late final GeneratedColumn<String> insuranceInfo = GeneratedColumn<String>(
    'insurance_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.synced),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    smarthealthPatientId,
    nationalId,
    passport,
    firstName,
    lastName,
    phone,
    email,
    gender,
    dateOfBirth,
    insuranceInfo,
    syncStatus,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Patient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('smarthealth_patient_id')) {
      context.handle(
        _smarthealthPatientIdMeta,
        smarthealthPatientId.isAcceptableOrUnknown(
          data['smarthealth_patient_id']!,
          _smarthealthPatientIdMeta,
        ),
      );
    }
    if (data.containsKey('national_id')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['national_id']!, _nationalIdMeta),
      );
    }
    if (data.containsKey('passport')) {
      context.handle(
        _passportMeta,
        passport.isAcceptableOrUnknown(data['passport']!, _passportMeta),
      );
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('insurance_info')) {
      context.handle(
        _insuranceInfoMeta,
        insuranceInfo.isAcceptableOrUnknown(
          data['insurance_info']!,
          _insuranceInfoMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      smarthealthPatientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}smarthealth_patient_id'],
      ),
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}national_id'],
      ),
      passport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passport'],
      ),
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      ),
      insuranceInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurance_info'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
  final String id;
  final String? serverId;
  final String? smarthealthPatientId;
  final String? nationalId;
  final String? passport;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? insuranceInfo;
  final String syncStatus;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Patient({
    required this.id,
    this.serverId,
    this.smarthealthPatientId,
    this.nationalId,
    this.passport,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.insuranceInfo,
    required this.syncStatus,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || smarthealthPatientId != null) {
      map['smarthealth_patient_id'] = Variable<String>(smarthealthPatientId);
    }
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    if (!nullToAbsent || passport != null) {
      map['passport'] = Variable<String>(passport);
    }
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || insuranceInfo != null) {
      map['insurance_info'] = Variable<String>(insuranceInfo);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      smarthealthPatientId: smarthealthPatientId == null && nullToAbsent
          ? const Value.absent()
          : Value(smarthealthPatientId),
      nationalId: nationalId == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalId),
      passport: passport == null && nullToAbsent
          ? const Value.absent()
          : Value(passport),
      firstName: Value(firstName),
      lastName: Value(lastName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      insuranceInfo: insuranceInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(insuranceInfo),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Patient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      smarthealthPatientId: serializer.fromJson<String?>(
        json['smarthealthPatientId'],
      ),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      passport: serializer.fromJson<String?>(json['passport']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      gender: serializer.fromJson<String?>(json['gender']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      insuranceInfo: serializer.fromJson<String?>(json['insuranceInfo']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'smarthealthPatientId': serializer.toJson<String?>(smarthealthPatientId),
      'nationalId': serializer.toJson<String?>(nationalId),
      'passport': serializer.toJson<String?>(passport),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'gender': serializer.toJson<String?>(gender),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'insuranceInfo': serializer.toJson<String?>(insuranceInfo),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Patient copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    Value<String?> smarthealthPatientId = const Value.absent(),
    Value<String?> nationalId = const Value.absent(),
    Value<String?> passport = const Value.absent(),
    String? firstName,
    String? lastName,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<DateTime?> dateOfBirth = const Value.absent(),
    Value<String?> insuranceInfo = const Value.absent(),
    String? syncStatus,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Patient(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    smarthealthPatientId: smarthealthPatientId.present
        ? smarthealthPatientId.value
        : this.smarthealthPatientId,
    nationalId: nationalId.present ? nationalId.value : this.nationalId,
    passport: passport.present ? passport.value : this.passport,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    gender: gender.present ? gender.value : this.gender,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    insuranceInfo: insuranceInfo.present
        ? insuranceInfo.value
        : this.insuranceInfo,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      smarthealthPatientId: data.smarthealthPatientId.present
          ? data.smarthealthPatientId.value
          : this.smarthealthPatientId,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      passport: data.passport.present ? data.passport.value : this.passport,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      gender: data.gender.present ? data.gender.value : this.gender,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      insuranceInfo: data.insuranceInfo.present
          ? data.insuranceInfo.value
          : this.insuranceInfo,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('smarthealthPatientId: $smarthealthPatientId, ')
          ..write('nationalId: $nationalId, ')
          ..write('passport: $passport, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('gender: $gender, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('insuranceInfo: $insuranceInfo, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    smarthealthPatientId,
    nationalId,
    passport,
    firstName,
    lastName,
    phone,
    email,
    gender,
    dateOfBirth,
    insuranceInfo,
    syncStatus,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.smarthealthPatientId == this.smarthealthPatientId &&
          other.nationalId == this.nationalId &&
          other.passport == this.passport &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.gender == this.gender &&
          other.dateOfBirth == this.dateOfBirth &&
          other.insuranceInfo == this.insuranceInfo &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String?> smarthealthPatientId;
  final Value<String?> nationalId;
  final Value<String?> passport;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> gender;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> insuranceInfo;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.smarthealthPatientId = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.passport = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.gender = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.insuranceInfo = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.smarthealthPatientId = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.passport = const Value.absent(),
    required String firstName,
    required String lastName,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.gender = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.insuranceInfo = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       firstName = Value(firstName),
       lastName = Value(lastName),
       updatedAt = Value(updatedAt);
  static Insertable<Patient> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? smarthealthPatientId,
    Expression<String>? nationalId,
    Expression<String>? passport,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? gender,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? insuranceInfo,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (smarthealthPatientId != null)
        'smarthealth_patient_id': smarthealthPatientId,
      if (nationalId != null) 'national_id': nationalId,
      if (passport != null) 'passport': passport,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (insuranceInfo != null) 'insurance_info': insuranceInfo,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String?>? smarthealthPatientId,
    Value<String?>? nationalId,
    Value<String?>? passport,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? gender,
    Value<DateTime?>? dateOfBirth,
    Value<String?>? insuranceInfo,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      smarthealthPatientId: smarthealthPatientId ?? this.smarthealthPatientId,
      nationalId: nationalId ?? this.nationalId,
      passport: passport ?? this.passport,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (smarthealthPatientId.present) {
      map['smarthealth_patient_id'] = Variable<String>(
        smarthealthPatientId.value,
      );
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (passport.present) {
      map['passport'] = Variable<String>(passport.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (insuranceInfo.present) {
      map['insurance_info'] = Variable<String>(insuranceInfo.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('smarthealthPatientId: $smarthealthPatientId, ')
          ..write('nationalId: $nationalId, ')
          ..write('passport: $passport, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('gender: $gender, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('insuranceInfo: $insuranceInfo, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientAllergiesTable extends PatientAllergies
    with TableInfo<$PatientAllergiesTable, PatientAllergy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientAllergiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _allergenMeta = const VerificationMeta(
    'allergen',
  );
  @override
  late final GeneratedColumn<String> allergen = GeneratedColumn<String>(
    'allergen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.synced),
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
    patientId,
    allergen,
    severity,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patient_allergies';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientAllergy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('allergen')) {
      context.handle(
        _allergenMeta,
        allergen.isAcceptableOrUnknown(data['allergen']!, _allergenMeta),
      );
    } else if (isInserting) {
      context.missing(_allergenMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  PatientAllergy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientAllergy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      allergen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergen'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PatientAllergiesTable createAlias(String alias) {
    return $PatientAllergiesTable(attachedDatabase, alias);
  }
}

class PatientAllergy extends DataClass implements Insertable<PatientAllergy> {
  final String id;
  final String patientId;
  final String allergen;
  final String? severity;
  final String syncStatus;
  final DateTime updatedAt;
  const PatientAllergy({
    required this.id,
    required this.patientId,
    required this.allergen,
    this.severity,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['allergen'] = Variable<String>(allergen);
    if (!nullToAbsent || severity != null) {
      map['severity'] = Variable<String>(severity);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PatientAllergiesCompanion toCompanion(bool nullToAbsent) {
    return PatientAllergiesCompanion(
      id: Value(id),
      patientId: Value(patientId),
      allergen: Value(allergen),
      severity: severity == null && nullToAbsent
          ? const Value.absent()
          : Value(severity),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory PatientAllergy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientAllergy(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      allergen: serializer.fromJson<String>(json['allergen']),
      severity: serializer.fromJson<String?>(json['severity']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'allergen': serializer.toJson<String>(allergen),
      'severity': serializer.toJson<String?>(severity),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PatientAllergy copyWith({
    String? id,
    String? patientId,
    String? allergen,
    Value<String?> severity = const Value.absent(),
    String? syncStatus,
    DateTime? updatedAt,
  }) => PatientAllergy(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    allergen: allergen ?? this.allergen,
    severity: severity.present ? severity.value : this.severity,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PatientAllergy copyWithCompanion(PatientAllergiesCompanion data) {
    return PatientAllergy(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      allergen: data.allergen.present ? data.allergen.value : this.allergen,
      severity: data.severity.present ? data.severity.value : this.severity,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientAllergy(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('allergen: $allergen, ')
          ..write('severity: $severity, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, patientId, allergen, severity, syncStatus, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientAllergy &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.allergen == this.allergen &&
          other.severity == this.severity &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class PatientAllergiesCompanion extends UpdateCompanion<PatientAllergy> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> allergen;
  final Value<String?> severity;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PatientAllergiesCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.allergen = const Value.absent(),
    this.severity = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientAllergiesCompanion.insert({
    required String id,
    required String patientId,
    required String allergen,
    this.severity = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       allergen = Value(allergen),
       updatedAt = Value(updatedAt);
  static Insertable<PatientAllergy> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? allergen,
    Expression<String>? severity,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (allergen != null) 'allergen': allergen,
      if (severity != null) 'severity': severity,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientAllergiesCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? allergen,
    Value<String?>? severity,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PatientAllergiesCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      allergen: allergen ?? this.allergen,
      severity: severity ?? this.severity,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (allergen.present) {
      map['allergen'] = Variable<String>(allergen.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('PatientAllergiesCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('allergen: $allergen, ')
          ..write('severity: $severity, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientConditionsTable extends PatientConditions
    with TableInfo<$PatientConditionsTable, PatientCondition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientConditionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _conditionNameMeta = const VerificationMeta(
    'conditionName',
  );
  @override
  late final GeneratedColumn<String> conditionName = GeneratedColumn<String>(
    'condition_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _icd11CodeMeta = const VerificationMeta(
    'icd11Code',
  );
  @override
  late final GeneratedColumn<String> icd11Code = GeneratedColumn<String>(
    'icd11_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.synced),
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
    patientId,
    conditionName,
    icd11Code,
    status,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patient_conditions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientCondition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('condition_name')) {
      context.handle(
        _conditionNameMeta,
        conditionName.isAcceptableOrUnknown(
          data['condition_name']!,
          _conditionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conditionNameMeta);
    }
    if (data.containsKey('icd11_code')) {
      context.handle(
        _icd11CodeMeta,
        icd11Code.isAcceptableOrUnknown(data['icd11_code']!, _icd11CodeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  PatientCondition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientCondition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      conditionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_name'],
      )!,
      icd11Code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icd11_code'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PatientConditionsTable createAlias(String alias) {
    return $PatientConditionsTable(attachedDatabase, alias);
  }
}

class PatientCondition extends DataClass
    implements Insertable<PatientCondition> {
  final String id;
  final String patientId;
  final String conditionName;
  final String? icd11Code;
  final String status;
  final String syncStatus;
  final DateTime updatedAt;
  const PatientCondition({
    required this.id,
    required this.patientId,
    required this.conditionName,
    this.icd11Code,
    required this.status,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['condition_name'] = Variable<String>(conditionName);
    if (!nullToAbsent || icd11Code != null) {
      map['icd11_code'] = Variable<String>(icd11Code);
    }
    map['status'] = Variable<String>(status);
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PatientConditionsCompanion toCompanion(bool nullToAbsent) {
    return PatientConditionsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      conditionName: Value(conditionName),
      icd11Code: icd11Code == null && nullToAbsent
          ? const Value.absent()
          : Value(icd11Code),
      status: Value(status),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory PatientCondition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientCondition(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      conditionName: serializer.fromJson<String>(json['conditionName']),
      icd11Code: serializer.fromJson<String?>(json['icd11Code']),
      status: serializer.fromJson<String>(json['status']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'conditionName': serializer.toJson<String>(conditionName),
      'icd11Code': serializer.toJson<String?>(icd11Code),
      'status': serializer.toJson<String>(status),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PatientCondition copyWith({
    String? id,
    String? patientId,
    String? conditionName,
    Value<String?> icd11Code = const Value.absent(),
    String? status,
    String? syncStatus,
    DateTime? updatedAt,
  }) => PatientCondition(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    conditionName: conditionName ?? this.conditionName,
    icd11Code: icd11Code.present ? icd11Code.value : this.icd11Code,
    status: status ?? this.status,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PatientCondition copyWithCompanion(PatientConditionsCompanion data) {
    return PatientCondition(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      conditionName: data.conditionName.present
          ? data.conditionName.value
          : this.conditionName,
      icd11Code: data.icd11Code.present ? data.icd11Code.value : this.icd11Code,
      status: data.status.present ? data.status.value : this.status,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientCondition(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('conditionName: $conditionName, ')
          ..write('icd11Code: $icd11Code, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    conditionName,
    icd11Code,
    status,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientCondition &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.conditionName == this.conditionName &&
          other.icd11Code == this.icd11Code &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class PatientConditionsCompanion extends UpdateCompanion<PatientCondition> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> conditionName;
  final Value<String?> icd11Code;
  final Value<String> status;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PatientConditionsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.conditionName = const Value.absent(),
    this.icd11Code = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientConditionsCompanion.insert({
    required String id,
    required String patientId,
    required String conditionName,
    this.icd11Code = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       conditionName = Value(conditionName),
       updatedAt = Value(updatedAt);
  static Insertable<PatientCondition> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? conditionName,
    Expression<String>? icd11Code,
    Expression<String>? status,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (conditionName != null) 'condition_name': conditionName,
      if (icd11Code != null) 'icd11_code': icd11Code,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientConditionsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? conditionName,
    Value<String?>? icd11Code,
    Value<String>? status,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PatientConditionsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      conditionName: conditionName ?? this.conditionName,
      icd11Code: icd11Code ?? this.icd11Code,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (conditionName.present) {
      map['condition_name'] = Variable<String>(conditionName.value);
    }
    if (icd11Code.present) {
      map['icd11_code'] = Variable<String>(icd11Code.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('PatientConditionsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('conditionName: $conditionName, ')
          ..write('icd11Code: $icd11Code, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, Appointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facilities (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appointmentTypeMeta = const VerificationMeta(
    'appointmentType',
  );
  @override
  late final GeneratedColumn<String> appointmentType = GeneratedColumn<String>(
    'appointment_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.synced),
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
    serverId,
    facilityId,
    providerId,
    patientId,
    referenceNumber,
    status,
    appointmentType,
    scheduledAt,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Appointment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('appointment_type')) {
      context.handle(
        _appointmentTypeMeta,
        appointmentType.isAcceptableOrUnknown(
          data['appointment_type']!,
          _appointmentTypeMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      appointmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appointment_type'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class Appointment extends DataClass implements Insertable<Appointment> {
  final String id;
  final String? serverId;
  final String facilityId;
  final String? providerId;
  final String patientId;
  final String? referenceNumber;
  final String status;
  final String? appointmentType;
  final DateTime scheduledAt;
  final String syncStatus;
  final DateTime updatedAt;
  const Appointment({
    required this.id,
    this.serverId,
    required this.facilityId,
    this.providerId,
    required this.patientId,
    this.referenceNumber,
    required this.status,
    this.appointmentType,
    required this.scheduledAt,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['facility_id'] = Variable<String>(facilityId);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || appointmentType != null) {
      map['appointment_type'] = Variable<String>(appointmentType);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      facilityId: Value(facilityId),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      patientId: Value(patientId),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      status: Value(status),
      appointmentType: appointmentType == null && nullToAbsent
          ? const Value.absent()
          : Value(appointmentType),
      scheduledAt: Value(scheduledAt),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory Appointment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      status: serializer.fromJson<String>(json['status']),
      appointmentType: serializer.fromJson<String?>(json['appointmentType']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'facilityId': serializer.toJson<String>(facilityId),
      'providerId': serializer.toJson<String?>(providerId),
      'patientId': serializer.toJson<String>(patientId),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'status': serializer.toJson<String>(status),
      'appointmentType': serializer.toJson<String?>(appointmentType),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Appointment copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? facilityId,
    Value<String?> providerId = const Value.absent(),
    String? patientId,
    Value<String?> referenceNumber = const Value.absent(),
    String? status,
    Value<String?> appointmentType = const Value.absent(),
    DateTime? scheduledAt,
    String? syncStatus,
    DateTime? updatedAt,
  }) => Appointment(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    facilityId: facilityId ?? this.facilityId,
    providerId: providerId.present ? providerId.value : this.providerId,
    patientId: patientId ?? this.patientId,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    status: status ?? this.status,
    appointmentType: appointmentType.present
        ? appointmentType.value
        : this.appointmentType,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      status: data.status.present ? data.status.value : this.status,
      appointmentType: data.appointmentType.present
          ? data.appointmentType.value
          : this.appointmentType,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('facilityId: $facilityId, ')
          ..write('providerId: $providerId, ')
          ..write('patientId: $patientId, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('status: $status, ')
          ..write('appointmentType: $appointmentType, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    facilityId,
    providerId,
    patientId,
    referenceNumber,
    status,
    appointmentType,
    scheduledAt,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.facilityId == this.facilityId &&
          other.providerId == this.providerId &&
          other.patientId == this.patientId &&
          other.referenceNumber == this.referenceNumber &&
          other.status == this.status &&
          other.appointmentType == this.appointmentType &&
          other.scheduledAt == this.scheduledAt &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> facilityId;
  final Value<String?> providerId;
  final Value<String> patientId;
  final Value<String?> referenceNumber;
  final Value<String> status;
  final Value<String?> appointmentType;
  final Value<DateTime> scheduledAt;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.appointmentType = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String facilityId,
    this.providerId = const Value.absent(),
    required String patientId,
    this.referenceNumber = const Value.absent(),
    required String status,
    this.appointmentType = const Value.absent(),
    required DateTime scheduledAt,
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityId = Value(facilityId),
       patientId = Value(patientId),
       status = Value(status),
       scheduledAt = Value(scheduledAt),
       updatedAt = Value(updatedAt);
  static Insertable<Appointment> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? facilityId,
    Expression<String>? providerId,
    Expression<String>? patientId,
    Expression<String>? referenceNumber,
    Expression<String>? status,
    Expression<String>? appointmentType,
    Expression<DateTime>? scheduledAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (facilityId != null) 'facility_id': facilityId,
      if (providerId != null) 'provider_id': providerId,
      if (patientId != null) 'patient_id': patientId,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (status != null) 'status': status,
      if (appointmentType != null) 'appointment_type': appointmentType,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppointmentsCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? facilityId,
    Value<String?>? providerId,
    Value<String>? patientId,
    Value<String?>? referenceNumber,
    Value<String>? status,
    Value<String?>? appointmentType,
    Value<DateTime>? scheduledAt,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      facilityId: facilityId ?? this.facilityId,
      providerId: providerId ?? this.providerId,
      patientId: patientId ?? this.patientId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      status: status ?? this.status,
      appointmentType: appointmentType ?? this.appointmentType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (appointmentType.present) {
      map['appointment_type'] = Variable<String>(appointmentType.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('facilityId: $facilityId, ')
          ..write('providerId: $providerId, ')
          ..write('patientId: $patientId, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('status: $status, ')
          ..write('appointmentType: $appointmentType, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueueEntriesTable extends QueueEntries
    with TableInfo<$QueueEntriesTable, QueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facilities (id)',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _appointmentIdMeta = const VerificationMeta(
    'appointmentId',
  );
  @override
  late final GeneratedColumn<String> appointmentId = GeneratedColumn<String>(
    'appointment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triageStatusMeta = const VerificationMeta(
    'triageStatus',
  );
  @override
  late final GeneratedColumn<String> triageStatus = GeneratedColumn<String>(
    'triage_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arrivedAtMeta = const VerificationMeta(
    'arrivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> arrivedAt = GeneratedColumn<DateTime>(
    'arrived_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.synced),
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
    serverId,
    facilityId,
    patientId,
    appointmentId,
    position,
    status,
    triageStatus,
    arrivedAt,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('appointment_id')) {
      context.handle(
        _appointmentIdMeta,
        appointmentId.isAcceptableOrUnknown(
          data['appointment_id']!,
          _appointmentIdMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('triage_status')) {
      context.handle(
        _triageStatusMeta,
        triageStatus.isAcceptableOrUnknown(
          data['triage_status']!,
          _triageStatusMeta,
        ),
      );
    }
    if (data.containsKey('arrived_at')) {
      context.handle(
        _arrivedAtMeta,
        arrivedAt.isAcceptableOrUnknown(data['arrived_at']!, _arrivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_arrivedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  QueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      appointmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appointment_id'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      triageStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}triage_status'],
      ),
      arrivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrived_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QueueEntriesTable createAlias(String alias) {
    return $QueueEntriesTable(attachedDatabase, alias);
  }
}

class QueueEntry extends DataClass implements Insertable<QueueEntry> {
  final String id;
  final String? serverId;
  final String facilityId;
  final String patientId;
  final String? appointmentId;
  final int position;
  final String status;
  final String? triageStatus;
  final DateTime arrivedAt;
  final String syncStatus;
  final DateTime updatedAt;
  const QueueEntry({
    required this.id,
    this.serverId,
    required this.facilityId,
    required this.patientId,
    this.appointmentId,
    required this.position,
    required this.status,
    this.triageStatus,
    required this.arrivedAt,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['facility_id'] = Variable<String>(facilityId);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || appointmentId != null) {
      map['appointment_id'] = Variable<String>(appointmentId);
    }
    map['position'] = Variable<int>(position);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || triageStatus != null) {
      map['triage_status'] = Variable<String>(triageStatus);
    }
    map['arrived_at'] = Variable<DateTime>(arrivedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return QueueEntriesCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      facilityId: Value(facilityId),
      patientId: Value(patientId),
      appointmentId: appointmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(appointmentId),
      position: Value(position),
      status: Value(status),
      triageStatus: triageStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(triageStatus),
      arrivedAt: Value(arrivedAt),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory QueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueEntry(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      appointmentId: serializer.fromJson<String?>(json['appointmentId']),
      position: serializer.fromJson<int>(json['position']),
      status: serializer.fromJson<String>(json['status']),
      triageStatus: serializer.fromJson<String?>(json['triageStatus']),
      arrivedAt: serializer.fromJson<DateTime>(json['arrivedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'facilityId': serializer.toJson<String>(facilityId),
      'patientId': serializer.toJson<String>(patientId),
      'appointmentId': serializer.toJson<String?>(appointmentId),
      'position': serializer.toJson<int>(position),
      'status': serializer.toJson<String>(status),
      'triageStatus': serializer.toJson<String?>(triageStatus),
      'arrivedAt': serializer.toJson<DateTime>(arrivedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QueueEntry copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? facilityId,
    String? patientId,
    Value<String?> appointmentId = const Value.absent(),
    int? position,
    String? status,
    Value<String?> triageStatus = const Value.absent(),
    DateTime? arrivedAt,
    String? syncStatus,
    DateTime? updatedAt,
  }) => QueueEntry(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    facilityId: facilityId ?? this.facilityId,
    patientId: patientId ?? this.patientId,
    appointmentId: appointmentId.present
        ? appointmentId.value
        : this.appointmentId,
    position: position ?? this.position,
    status: status ?? this.status,
    triageStatus: triageStatus.present ? triageStatus.value : this.triageStatus,
    arrivedAt: arrivedAt ?? this.arrivedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QueueEntry copyWithCompanion(QueueEntriesCompanion data) {
    return QueueEntry(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      appointmentId: data.appointmentId.present
          ? data.appointmentId.value
          : this.appointmentId,
      position: data.position.present ? data.position.value : this.position,
      status: data.status.present ? data.status.value : this.status,
      triageStatus: data.triageStatus.present
          ? data.triageStatus.value
          : this.triageStatus,
      arrivedAt: data.arrivedAt.present ? data.arrivedAt.value : this.arrivedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueEntry(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('facilityId: $facilityId, ')
          ..write('patientId: $patientId, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('position: $position, ')
          ..write('status: $status, ')
          ..write('triageStatus: $triageStatus, ')
          ..write('arrivedAt: $arrivedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    facilityId,
    patientId,
    appointmentId,
    position,
    status,
    triageStatus,
    arrivedAt,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueEntry &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.facilityId == this.facilityId &&
          other.patientId == this.patientId &&
          other.appointmentId == this.appointmentId &&
          other.position == this.position &&
          other.status == this.status &&
          other.triageStatus == this.triageStatus &&
          other.arrivedAt == this.arrivedAt &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class QueueEntriesCompanion extends UpdateCompanion<QueueEntry> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> facilityId;
  final Value<String> patientId;
  final Value<String?> appointmentId;
  final Value<int> position;
  final Value<String> status;
  final Value<String?> triageStatus;
  final Value<DateTime> arrivedAt;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QueueEntriesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.appointmentId = const Value.absent(),
    this.position = const Value.absent(),
    this.status = const Value.absent(),
    this.triageStatus = const Value.absent(),
    this.arrivedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueueEntriesCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String facilityId,
    required String patientId,
    this.appointmentId = const Value.absent(),
    this.position = const Value.absent(),
    required String status,
    this.triageStatus = const Value.absent(),
    required DateTime arrivedAt,
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityId = Value(facilityId),
       patientId = Value(patientId),
       status = Value(status),
       arrivedAt = Value(arrivedAt),
       updatedAt = Value(updatedAt);
  static Insertable<QueueEntry> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? facilityId,
    Expression<String>? patientId,
    Expression<String>? appointmentId,
    Expression<int>? position,
    Expression<String>? status,
    Expression<String>? triageStatus,
    Expression<DateTime>? arrivedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (facilityId != null) 'facility_id': facilityId,
      if (patientId != null) 'patient_id': patientId,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (position != null) 'position': position,
      if (status != null) 'status': status,
      if (triageStatus != null) 'triage_status': triageStatus,
      if (arrivedAt != null) 'arrived_at': arrivedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueueEntriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? facilityId,
    Value<String>? patientId,
    Value<String?>? appointmentId,
    Value<int>? position,
    Value<String>? status,
    Value<String?>? triageStatus,
    Value<DateTime>? arrivedAt,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return QueueEntriesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      facilityId: facilityId ?? this.facilityId,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId,
      position: position ?? this.position,
      status: status ?? this.status,
      triageStatus: triageStatus ?? this.triageStatus,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (appointmentId.present) {
      map['appointment_id'] = Variable<String>(appointmentId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (triageStatus.present) {
      map['triage_status'] = Variable<String>(triageStatus.value);
    }
    if (arrivedAt.present) {
      map['arrived_at'] = Variable<DateTime>(arrivedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('QueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('facilityId: $facilityId, ')
          ..write('patientId: $patientId, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('position: $position, ')
          ..write('status: $status, ')
          ..write('triageStatus: $triageStatus, ')
          ..write('arrivedAt: $arrivedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsultationsTable extends Consultations
    with TableInfo<$ConsultationsTable, Consultation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsultationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facilities (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _appointmentIdMeta = const VerificationMeta(
    'appointmentId',
  );
  @override
  late final GeneratedColumn<String> appointmentId = GeneratedColumn<String>(
    'appointment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('in_progress'),
  );
  static const VerificationMeta _chiefComplaintMeta = const VerificationMeta(
    'chiefComplaint',
  );
  @override
  late final GeneratedColumn<String> chiefComplaint = GeneratedColumn<String>(
    'chief_complaint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _historyOfPresentIllnessMeta =
      const VerificationMeta('historyOfPresentIllness');
  @override
  late final GeneratedColumn<String> historyOfPresentIllness =
      GeneratedColumn<String>(
        'history_of_present_illness',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pastMedicalHistoryMeta =
      const VerificationMeta('pastMedicalHistory');
  @override
  late final GeneratedColumn<String> pastMedicalHistory =
      GeneratedColumn<String>(
        'past_medical_history',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _surgicalHistoryMeta = const VerificationMeta(
    'surgicalHistory',
  );
  @override
  late final GeneratedColumn<String> surgicalHistory = GeneratedColumn<String>(
    'surgical_history',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyHistoryMeta = const VerificationMeta(
    'familyHistory',
  );
  @override
  late final GeneratedColumn<String> familyHistory = GeneratedColumn<String>(
    'family_history',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _socialHistoryMeta = const VerificationMeta(
    'socialHistory',
  );
  @override
  late final GeneratedColumn<String> socialHistory = GeneratedColumn<String>(
    'social_history',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _examinationNotesMeta = const VerificationMeta(
    'examinationNotes',
  );
  @override
  late final GeneratedColumn<String> examinationNotes = GeneratedColumn<String>(
    'examination_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assessmentMeta = const VerificationMeta(
    'assessment',
  );
  @override
  late final GeneratedColumn<String> assessment = GeneratedColumn<String>(
    'assessment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
    'plan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _followUpPlanMeta = const VerificationMeta(
    'followUpPlan',
  );
  @override
  late final GeneratedColumn<String> followUpPlan = GeneratedColumn<String>(
    'follow_up_plan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.pending),
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
    serverId,
    facilityId,
    providerId,
    patientId,
    appointmentId,
    status,
    chiefComplaint,
    historyOfPresentIllness,
    pastMedicalHistory,
    surgicalHistory,
    familyHistory,
    socialHistory,
    examinationNotes,
    assessment,
    plan,
    followUpPlan,
    startedAt,
    completedAt,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consultations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Consultation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('appointment_id')) {
      context.handle(
        _appointmentIdMeta,
        appointmentId.isAcceptableOrUnknown(
          data['appointment_id']!,
          _appointmentIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('chief_complaint')) {
      context.handle(
        _chiefComplaintMeta,
        chiefComplaint.isAcceptableOrUnknown(
          data['chief_complaint']!,
          _chiefComplaintMeta,
        ),
      );
    }
    if (data.containsKey('history_of_present_illness')) {
      context.handle(
        _historyOfPresentIllnessMeta,
        historyOfPresentIllness.isAcceptableOrUnknown(
          data['history_of_present_illness']!,
          _historyOfPresentIllnessMeta,
        ),
      );
    }
    if (data.containsKey('past_medical_history')) {
      context.handle(
        _pastMedicalHistoryMeta,
        pastMedicalHistory.isAcceptableOrUnknown(
          data['past_medical_history']!,
          _pastMedicalHistoryMeta,
        ),
      );
    }
    if (data.containsKey('surgical_history')) {
      context.handle(
        _surgicalHistoryMeta,
        surgicalHistory.isAcceptableOrUnknown(
          data['surgical_history']!,
          _surgicalHistoryMeta,
        ),
      );
    }
    if (data.containsKey('family_history')) {
      context.handle(
        _familyHistoryMeta,
        familyHistory.isAcceptableOrUnknown(
          data['family_history']!,
          _familyHistoryMeta,
        ),
      );
    }
    if (data.containsKey('social_history')) {
      context.handle(
        _socialHistoryMeta,
        socialHistory.isAcceptableOrUnknown(
          data['social_history']!,
          _socialHistoryMeta,
        ),
      );
    }
    if (data.containsKey('examination_notes')) {
      context.handle(
        _examinationNotesMeta,
        examinationNotes.isAcceptableOrUnknown(
          data['examination_notes']!,
          _examinationNotesMeta,
        ),
      );
    }
    if (data.containsKey('assessment')) {
      context.handle(
        _assessmentMeta,
        assessment.isAcceptableOrUnknown(data['assessment']!, _assessmentMeta),
      );
    }
    if (data.containsKey('plan')) {
      context.handle(
        _planMeta,
        plan.isAcceptableOrUnknown(data['plan']!, _planMeta),
      );
    }
    if (data.containsKey('follow_up_plan')) {
      context.handle(
        _followUpPlanMeta,
        followUpPlan.isAcceptableOrUnknown(
          data['follow_up_plan']!,
          _followUpPlanMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  Consultation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Consultation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      appointmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appointment_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      chiefComplaint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chief_complaint'],
      ),
      historyOfPresentIllness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}history_of_present_illness'],
      ),
      pastMedicalHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}past_medical_history'],
      ),
      surgicalHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surgical_history'],
      ),
      familyHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_history'],
      ),
      socialHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}social_history'],
      ),
      examinationNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examination_notes'],
      ),
      assessment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment'],
      ),
      plan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan'],
      ),
      followUpPlan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}follow_up_plan'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConsultationsTable createAlias(String alias) {
    return $ConsultationsTable(attachedDatabase, alias);
  }
}

class Consultation extends DataClass implements Insertable<Consultation> {
  final String id;
  final String? serverId;
  final String facilityId;
  final String providerId;
  final String patientId;
  final String? appointmentId;
  final String status;
  final String? chiefComplaint;
  final String? historyOfPresentIllness;
  final String? pastMedicalHistory;
  final String? surgicalHistory;
  final String? familyHistory;
  final String? socialHistory;
  final String? examinationNotes;
  final String? assessment;
  final String? plan;
  final String? followUpPlan;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String syncStatus;
  final DateTime updatedAt;
  const Consultation({
    required this.id,
    this.serverId,
    required this.facilityId,
    required this.providerId,
    required this.patientId,
    this.appointmentId,
    required this.status,
    this.chiefComplaint,
    this.historyOfPresentIllness,
    this.pastMedicalHistory,
    this.surgicalHistory,
    this.familyHistory,
    this.socialHistory,
    this.examinationNotes,
    this.assessment,
    this.plan,
    this.followUpPlan,
    this.startedAt,
    this.completedAt,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['facility_id'] = Variable<String>(facilityId);
    map['provider_id'] = Variable<String>(providerId);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || appointmentId != null) {
      map['appointment_id'] = Variable<String>(appointmentId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || chiefComplaint != null) {
      map['chief_complaint'] = Variable<String>(chiefComplaint);
    }
    if (!nullToAbsent || historyOfPresentIllness != null) {
      map['history_of_present_illness'] = Variable<String>(
        historyOfPresentIllness,
      );
    }
    if (!nullToAbsent || pastMedicalHistory != null) {
      map['past_medical_history'] = Variable<String>(pastMedicalHistory);
    }
    if (!nullToAbsent || surgicalHistory != null) {
      map['surgical_history'] = Variable<String>(surgicalHistory);
    }
    if (!nullToAbsent || familyHistory != null) {
      map['family_history'] = Variable<String>(familyHistory);
    }
    if (!nullToAbsent || socialHistory != null) {
      map['social_history'] = Variable<String>(socialHistory);
    }
    if (!nullToAbsent || examinationNotes != null) {
      map['examination_notes'] = Variable<String>(examinationNotes);
    }
    if (!nullToAbsent || assessment != null) {
      map['assessment'] = Variable<String>(assessment);
    }
    if (!nullToAbsent || plan != null) {
      map['plan'] = Variable<String>(plan);
    }
    if (!nullToAbsent || followUpPlan != null) {
      map['follow_up_plan'] = Variable<String>(followUpPlan);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConsultationsCompanion toCompanion(bool nullToAbsent) {
    return ConsultationsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      facilityId: Value(facilityId),
      providerId: Value(providerId),
      patientId: Value(patientId),
      appointmentId: appointmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(appointmentId),
      status: Value(status),
      chiefComplaint: chiefComplaint == null && nullToAbsent
          ? const Value.absent()
          : Value(chiefComplaint),
      historyOfPresentIllness: historyOfPresentIllness == null && nullToAbsent
          ? const Value.absent()
          : Value(historyOfPresentIllness),
      pastMedicalHistory: pastMedicalHistory == null && nullToAbsent
          ? const Value.absent()
          : Value(pastMedicalHistory),
      surgicalHistory: surgicalHistory == null && nullToAbsent
          ? const Value.absent()
          : Value(surgicalHistory),
      familyHistory: familyHistory == null && nullToAbsent
          ? const Value.absent()
          : Value(familyHistory),
      socialHistory: socialHistory == null && nullToAbsent
          ? const Value.absent()
          : Value(socialHistory),
      examinationNotes: examinationNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(examinationNotes),
      assessment: assessment == null && nullToAbsent
          ? const Value.absent()
          : Value(assessment),
      plan: plan == null && nullToAbsent ? const Value.absent() : Value(plan),
      followUpPlan: followUpPlan == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpPlan),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory Consultation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Consultation(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      appointmentId: serializer.fromJson<String?>(json['appointmentId']),
      status: serializer.fromJson<String>(json['status']),
      chiefComplaint: serializer.fromJson<String?>(json['chiefComplaint']),
      historyOfPresentIllness: serializer.fromJson<String?>(
        json['historyOfPresentIllness'],
      ),
      pastMedicalHistory: serializer.fromJson<String?>(
        json['pastMedicalHistory'],
      ),
      surgicalHistory: serializer.fromJson<String?>(json['surgicalHistory']),
      familyHistory: serializer.fromJson<String?>(json['familyHistory']),
      socialHistory: serializer.fromJson<String?>(json['socialHistory']),
      examinationNotes: serializer.fromJson<String?>(json['examinationNotes']),
      assessment: serializer.fromJson<String?>(json['assessment']),
      plan: serializer.fromJson<String?>(json['plan']),
      followUpPlan: serializer.fromJson<String?>(json['followUpPlan']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'facilityId': serializer.toJson<String>(facilityId),
      'providerId': serializer.toJson<String>(providerId),
      'patientId': serializer.toJson<String>(patientId),
      'appointmentId': serializer.toJson<String?>(appointmentId),
      'status': serializer.toJson<String>(status),
      'chiefComplaint': serializer.toJson<String?>(chiefComplaint),
      'historyOfPresentIllness': serializer.toJson<String?>(
        historyOfPresentIllness,
      ),
      'pastMedicalHistory': serializer.toJson<String?>(pastMedicalHistory),
      'surgicalHistory': serializer.toJson<String?>(surgicalHistory),
      'familyHistory': serializer.toJson<String?>(familyHistory),
      'socialHistory': serializer.toJson<String?>(socialHistory),
      'examinationNotes': serializer.toJson<String?>(examinationNotes),
      'assessment': serializer.toJson<String?>(assessment),
      'plan': serializer.toJson<String?>(plan),
      'followUpPlan': serializer.toJson<String?>(followUpPlan),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Consultation copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? facilityId,
    String? providerId,
    String? patientId,
    Value<String?> appointmentId = const Value.absent(),
    String? status,
    Value<String?> chiefComplaint = const Value.absent(),
    Value<String?> historyOfPresentIllness = const Value.absent(),
    Value<String?> pastMedicalHistory = const Value.absent(),
    Value<String?> surgicalHistory = const Value.absent(),
    Value<String?> familyHistory = const Value.absent(),
    Value<String?> socialHistory = const Value.absent(),
    Value<String?> examinationNotes = const Value.absent(),
    Value<String?> assessment = const Value.absent(),
    Value<String?> plan = const Value.absent(),
    Value<String?> followUpPlan = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    String? syncStatus,
    DateTime? updatedAt,
  }) => Consultation(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    facilityId: facilityId ?? this.facilityId,
    providerId: providerId ?? this.providerId,
    patientId: patientId ?? this.patientId,
    appointmentId: appointmentId.present
        ? appointmentId.value
        : this.appointmentId,
    status: status ?? this.status,
    chiefComplaint: chiefComplaint.present
        ? chiefComplaint.value
        : this.chiefComplaint,
    historyOfPresentIllness: historyOfPresentIllness.present
        ? historyOfPresentIllness.value
        : this.historyOfPresentIllness,
    pastMedicalHistory: pastMedicalHistory.present
        ? pastMedicalHistory.value
        : this.pastMedicalHistory,
    surgicalHistory: surgicalHistory.present
        ? surgicalHistory.value
        : this.surgicalHistory,
    familyHistory: familyHistory.present
        ? familyHistory.value
        : this.familyHistory,
    socialHistory: socialHistory.present
        ? socialHistory.value
        : this.socialHistory,
    examinationNotes: examinationNotes.present
        ? examinationNotes.value
        : this.examinationNotes,
    assessment: assessment.present ? assessment.value : this.assessment,
    plan: plan.present ? plan.value : this.plan,
    followUpPlan: followUpPlan.present ? followUpPlan.value : this.followUpPlan,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Consultation copyWithCompanion(ConsultationsCompanion data) {
    return Consultation(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      appointmentId: data.appointmentId.present
          ? data.appointmentId.value
          : this.appointmentId,
      status: data.status.present ? data.status.value : this.status,
      chiefComplaint: data.chiefComplaint.present
          ? data.chiefComplaint.value
          : this.chiefComplaint,
      historyOfPresentIllness: data.historyOfPresentIllness.present
          ? data.historyOfPresentIllness.value
          : this.historyOfPresentIllness,
      pastMedicalHistory: data.pastMedicalHistory.present
          ? data.pastMedicalHistory.value
          : this.pastMedicalHistory,
      surgicalHistory: data.surgicalHistory.present
          ? data.surgicalHistory.value
          : this.surgicalHistory,
      familyHistory: data.familyHistory.present
          ? data.familyHistory.value
          : this.familyHistory,
      socialHistory: data.socialHistory.present
          ? data.socialHistory.value
          : this.socialHistory,
      examinationNotes: data.examinationNotes.present
          ? data.examinationNotes.value
          : this.examinationNotes,
      assessment: data.assessment.present
          ? data.assessment.value
          : this.assessment,
      plan: data.plan.present ? data.plan.value : this.plan,
      followUpPlan: data.followUpPlan.present
          ? data.followUpPlan.value
          : this.followUpPlan,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Consultation(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('facilityId: $facilityId, ')
          ..write('providerId: $providerId, ')
          ..write('patientId: $patientId, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('status: $status, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('historyOfPresentIllness: $historyOfPresentIllness, ')
          ..write('pastMedicalHistory: $pastMedicalHistory, ')
          ..write('surgicalHistory: $surgicalHistory, ')
          ..write('familyHistory: $familyHistory, ')
          ..write('socialHistory: $socialHistory, ')
          ..write('examinationNotes: $examinationNotes, ')
          ..write('assessment: $assessment, ')
          ..write('plan: $plan, ')
          ..write('followUpPlan: $followUpPlan, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    serverId,
    facilityId,
    providerId,
    patientId,
    appointmentId,
    status,
    chiefComplaint,
    historyOfPresentIllness,
    pastMedicalHistory,
    surgicalHistory,
    familyHistory,
    socialHistory,
    examinationNotes,
    assessment,
    plan,
    followUpPlan,
    startedAt,
    completedAt,
    syncStatus,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Consultation &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.facilityId == this.facilityId &&
          other.providerId == this.providerId &&
          other.patientId == this.patientId &&
          other.appointmentId == this.appointmentId &&
          other.status == this.status &&
          other.chiefComplaint == this.chiefComplaint &&
          other.historyOfPresentIllness == this.historyOfPresentIllness &&
          other.pastMedicalHistory == this.pastMedicalHistory &&
          other.surgicalHistory == this.surgicalHistory &&
          other.familyHistory == this.familyHistory &&
          other.socialHistory == this.socialHistory &&
          other.examinationNotes == this.examinationNotes &&
          other.assessment == this.assessment &&
          other.plan == this.plan &&
          other.followUpPlan == this.followUpPlan &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class ConsultationsCompanion extends UpdateCompanion<Consultation> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> facilityId;
  final Value<String> providerId;
  final Value<String> patientId;
  final Value<String?> appointmentId;
  final Value<String> status;
  final Value<String?> chiefComplaint;
  final Value<String?> historyOfPresentIllness;
  final Value<String?> pastMedicalHistory;
  final Value<String?> surgicalHistory;
  final Value<String?> familyHistory;
  final Value<String?> socialHistory;
  final Value<String?> examinationNotes;
  final Value<String?> assessment;
  final Value<String?> plan;
  final Value<String?> followUpPlan;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConsultationsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.appointmentId = const Value.absent(),
    this.status = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.historyOfPresentIllness = const Value.absent(),
    this.pastMedicalHistory = const Value.absent(),
    this.surgicalHistory = const Value.absent(),
    this.familyHistory = const Value.absent(),
    this.socialHistory = const Value.absent(),
    this.examinationNotes = const Value.absent(),
    this.assessment = const Value.absent(),
    this.plan = const Value.absent(),
    this.followUpPlan = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsultationsCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String facilityId,
    required String providerId,
    required String patientId,
    this.appointmentId = const Value.absent(),
    this.status = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.historyOfPresentIllness = const Value.absent(),
    this.pastMedicalHistory = const Value.absent(),
    this.surgicalHistory = const Value.absent(),
    this.familyHistory = const Value.absent(),
    this.socialHistory = const Value.absent(),
    this.examinationNotes = const Value.absent(),
    this.assessment = const Value.absent(),
    this.plan = const Value.absent(),
    this.followUpPlan = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityId = Value(facilityId),
       providerId = Value(providerId),
       patientId = Value(patientId),
       updatedAt = Value(updatedAt);
  static Insertable<Consultation> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? facilityId,
    Expression<String>? providerId,
    Expression<String>? patientId,
    Expression<String>? appointmentId,
    Expression<String>? status,
    Expression<String>? chiefComplaint,
    Expression<String>? historyOfPresentIllness,
    Expression<String>? pastMedicalHistory,
    Expression<String>? surgicalHistory,
    Expression<String>? familyHistory,
    Expression<String>? socialHistory,
    Expression<String>? examinationNotes,
    Expression<String>? assessment,
    Expression<String>? plan,
    Expression<String>? followUpPlan,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (facilityId != null) 'facility_id': facilityId,
      if (providerId != null) 'provider_id': providerId,
      if (patientId != null) 'patient_id': patientId,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (status != null) 'status': status,
      if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
      if (historyOfPresentIllness != null)
        'history_of_present_illness': historyOfPresentIllness,
      if (pastMedicalHistory != null)
        'past_medical_history': pastMedicalHistory,
      if (surgicalHistory != null) 'surgical_history': surgicalHistory,
      if (familyHistory != null) 'family_history': familyHistory,
      if (socialHistory != null) 'social_history': socialHistory,
      if (examinationNotes != null) 'examination_notes': examinationNotes,
      if (assessment != null) 'assessment': assessment,
      if (plan != null) 'plan': plan,
      if (followUpPlan != null) 'follow_up_plan': followUpPlan,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsultationsCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? facilityId,
    Value<String>? providerId,
    Value<String>? patientId,
    Value<String?>? appointmentId,
    Value<String>? status,
    Value<String?>? chiefComplaint,
    Value<String?>? historyOfPresentIllness,
    Value<String?>? pastMedicalHistory,
    Value<String?>? surgicalHistory,
    Value<String?>? familyHistory,
    Value<String?>? socialHistory,
    Value<String?>? examinationNotes,
    Value<String?>? assessment,
    Value<String?>? plan,
    Value<String?>? followUpPlan,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ConsultationsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      facilityId: facilityId ?? this.facilityId,
      providerId: providerId ?? this.providerId,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId,
      status: status ?? this.status,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      historyOfPresentIllness:
          historyOfPresentIllness ?? this.historyOfPresentIllness,
      pastMedicalHistory: pastMedicalHistory ?? this.pastMedicalHistory,
      surgicalHistory: surgicalHistory ?? this.surgicalHistory,
      familyHistory: familyHistory ?? this.familyHistory,
      socialHistory: socialHistory ?? this.socialHistory,
      examinationNotes: examinationNotes ?? this.examinationNotes,
      assessment: assessment ?? this.assessment,
      plan: plan ?? this.plan,
      followUpPlan: followUpPlan ?? this.followUpPlan,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (appointmentId.present) {
      map['appointment_id'] = Variable<String>(appointmentId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (chiefComplaint.present) {
      map['chief_complaint'] = Variable<String>(chiefComplaint.value);
    }
    if (historyOfPresentIllness.present) {
      map['history_of_present_illness'] = Variable<String>(
        historyOfPresentIllness.value,
      );
    }
    if (pastMedicalHistory.present) {
      map['past_medical_history'] = Variable<String>(pastMedicalHistory.value);
    }
    if (surgicalHistory.present) {
      map['surgical_history'] = Variable<String>(surgicalHistory.value);
    }
    if (familyHistory.present) {
      map['family_history'] = Variable<String>(familyHistory.value);
    }
    if (socialHistory.present) {
      map['social_history'] = Variable<String>(socialHistory.value);
    }
    if (examinationNotes.present) {
      map['examination_notes'] = Variable<String>(examinationNotes.value);
    }
    if (assessment.present) {
      map['assessment'] = Variable<String>(assessment.value);
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (followUpPlan.present) {
      map['follow_up_plan'] = Variable<String>(followUpPlan.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('ConsultationsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('facilityId: $facilityId, ')
          ..write('providerId: $providerId, ')
          ..write('patientId: $patientId, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('status: $status, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('historyOfPresentIllness: $historyOfPresentIllness, ')
          ..write('pastMedicalHistory: $pastMedicalHistory, ')
          ..write('surgicalHistory: $surgicalHistory, ')
          ..write('familyHistory: $familyHistory, ')
          ..write('socialHistory: $socialHistory, ')
          ..write('examinationNotes: $examinationNotes, ')
          ..write('assessment: $assessment, ')
          ..write('plan: $plan, ')
          ..write('followUpPlan: $followUpPlan, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiagnosesTable extends Diagnoses
    with TableInfo<$DiagnosesTable, Diagnose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consultationIdMeta = const VerificationMeta(
    'consultationId',
  );
  @override
  late final GeneratedColumn<String> consultationId = GeneratedColumn<String>(
    'consultation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES consultations (id)',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _icd11CodeMeta = const VerificationMeta(
    'icd11Code',
  );
  @override
  late final GeneratedColumn<String> icd11Code = GeneratedColumn<String>(
    'icd11_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _icd10CodeMeta = const VerificationMeta(
    'icd10Code',
  );
  @override
  late final GeneratedColumn<String> icd10Code = GeneratedColumn<String>(
    'icd10_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.pending),
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
    consultationId,
    patientId,
    providerId,
    facilityId,
    icd11Code,
    icd10Code,
    description,
    isPrimary,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnoses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Diagnose> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('consultation_id')) {
      context.handle(
        _consultationIdMeta,
        consultationId.isAcceptableOrUnknown(
          data['consultation_id']!,
          _consultationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consultationIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('icd11_code')) {
      context.handle(
        _icd11CodeMeta,
        icd11Code.isAcceptableOrUnknown(data['icd11_code']!, _icd11CodeMeta),
      );
    }
    if (data.containsKey('icd10_code')) {
      context.handle(
        _icd10CodeMeta,
        icd10Code.isAcceptableOrUnknown(data['icd10_code']!, _icd10CodeMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  Diagnose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Diagnose(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      consultationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consultation_id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      icd11Code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icd11_code'],
      ),
      icd10Code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icd10_code'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DiagnosesTable createAlias(String alias) {
    return $DiagnosesTable(attachedDatabase, alias);
  }
}

class Diagnose extends DataClass implements Insertable<Diagnose> {
  final String id;
  final String consultationId;
  final String patientId;
  final String providerId;
  final String facilityId;
  final String? icd11Code;
  final String? icd10Code;
  final String description;
  final bool isPrimary;
  final String syncStatus;
  final DateTime updatedAt;
  const Diagnose({
    required this.id,
    required this.consultationId,
    required this.patientId,
    required this.providerId,
    required this.facilityId,
    this.icd11Code,
    this.icd10Code,
    required this.description,
    required this.isPrimary,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['consultation_id'] = Variable<String>(consultationId);
    map['patient_id'] = Variable<String>(patientId);
    map['provider_id'] = Variable<String>(providerId);
    map['facility_id'] = Variable<String>(facilityId);
    if (!nullToAbsent || icd11Code != null) {
      map['icd11_code'] = Variable<String>(icd11Code);
    }
    if (!nullToAbsent || icd10Code != null) {
      map['icd10_code'] = Variable<String>(icd10Code);
    }
    map['description'] = Variable<String>(description);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DiagnosesCompanion toCompanion(bool nullToAbsent) {
    return DiagnosesCompanion(
      id: Value(id),
      consultationId: Value(consultationId),
      patientId: Value(patientId),
      providerId: Value(providerId),
      facilityId: Value(facilityId),
      icd11Code: icd11Code == null && nullToAbsent
          ? const Value.absent()
          : Value(icd11Code),
      icd10Code: icd10Code == null && nullToAbsent
          ? const Value.absent()
          : Value(icd10Code),
      description: Value(description),
      isPrimary: Value(isPrimary),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory Diagnose.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Diagnose(
      id: serializer.fromJson<String>(json['id']),
      consultationId: serializer.fromJson<String>(json['consultationId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      icd11Code: serializer.fromJson<String?>(json['icd11Code']),
      icd10Code: serializer.fromJson<String?>(json['icd10Code']),
      description: serializer.fromJson<String>(json['description']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'consultationId': serializer.toJson<String>(consultationId),
      'patientId': serializer.toJson<String>(patientId),
      'providerId': serializer.toJson<String>(providerId),
      'facilityId': serializer.toJson<String>(facilityId),
      'icd11Code': serializer.toJson<String?>(icd11Code),
      'icd10Code': serializer.toJson<String?>(icd10Code),
      'description': serializer.toJson<String>(description),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Diagnose copyWith({
    String? id,
    String? consultationId,
    String? patientId,
    String? providerId,
    String? facilityId,
    Value<String?> icd11Code = const Value.absent(),
    Value<String?> icd10Code = const Value.absent(),
    String? description,
    bool? isPrimary,
    String? syncStatus,
    DateTime? updatedAt,
  }) => Diagnose(
    id: id ?? this.id,
    consultationId: consultationId ?? this.consultationId,
    patientId: patientId ?? this.patientId,
    providerId: providerId ?? this.providerId,
    facilityId: facilityId ?? this.facilityId,
    icd11Code: icd11Code.present ? icd11Code.value : this.icd11Code,
    icd10Code: icd10Code.present ? icd10Code.value : this.icd10Code,
    description: description ?? this.description,
    isPrimary: isPrimary ?? this.isPrimary,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Diagnose copyWithCompanion(DiagnosesCompanion data) {
    return Diagnose(
      id: data.id.present ? data.id.value : this.id,
      consultationId: data.consultationId.present
          ? data.consultationId.value
          : this.consultationId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      icd11Code: data.icd11Code.present ? data.icd11Code.value : this.icd11Code,
      icd10Code: data.icd10Code.present ? data.icd10Code.value : this.icd10Code,
      description: data.description.present
          ? data.description.value
          : this.description,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Diagnose(')
          ..write('id: $id, ')
          ..write('consultationId: $consultationId, ')
          ..write('patientId: $patientId, ')
          ..write('providerId: $providerId, ')
          ..write('facilityId: $facilityId, ')
          ..write('icd11Code: $icd11Code, ')
          ..write('icd10Code: $icd10Code, ')
          ..write('description: $description, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    consultationId,
    patientId,
    providerId,
    facilityId,
    icd11Code,
    icd10Code,
    description,
    isPrimary,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Diagnose &&
          other.id == this.id &&
          other.consultationId == this.consultationId &&
          other.patientId == this.patientId &&
          other.providerId == this.providerId &&
          other.facilityId == this.facilityId &&
          other.icd11Code == this.icd11Code &&
          other.icd10Code == this.icd10Code &&
          other.description == this.description &&
          other.isPrimary == this.isPrimary &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class DiagnosesCompanion extends UpdateCompanion<Diagnose> {
  final Value<String> id;
  final Value<String> consultationId;
  final Value<String> patientId;
  final Value<String> providerId;
  final Value<String> facilityId;
  final Value<String?> icd11Code;
  final Value<String?> icd10Code;
  final Value<String> description;
  final Value<bool> isPrimary;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DiagnosesCompanion({
    this.id = const Value.absent(),
    this.consultationId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.icd11Code = const Value.absent(),
    this.icd10Code = const Value.absent(),
    this.description = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiagnosesCompanion.insert({
    required String id,
    required String consultationId,
    required String patientId,
    required String providerId,
    required String facilityId,
    this.icd11Code = const Value.absent(),
    this.icd10Code = const Value.absent(),
    required String description,
    this.isPrimary = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       consultationId = Value(consultationId),
       patientId = Value(patientId),
       providerId = Value(providerId),
       facilityId = Value(facilityId),
       description = Value(description),
       updatedAt = Value(updatedAt);
  static Insertable<Diagnose> custom({
    Expression<String>? id,
    Expression<String>? consultationId,
    Expression<String>? patientId,
    Expression<String>? providerId,
    Expression<String>? facilityId,
    Expression<String>? icd11Code,
    Expression<String>? icd10Code,
    Expression<String>? description,
    Expression<bool>? isPrimary,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (consultationId != null) 'consultation_id': consultationId,
      if (patientId != null) 'patient_id': patientId,
      if (providerId != null) 'provider_id': providerId,
      if (facilityId != null) 'facility_id': facilityId,
      if (icd11Code != null) 'icd11_code': icd11Code,
      if (icd10Code != null) 'icd10_code': icd10Code,
      if (description != null) 'description': description,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiagnosesCompanion copyWith({
    Value<String>? id,
    Value<String>? consultationId,
    Value<String>? patientId,
    Value<String>? providerId,
    Value<String>? facilityId,
    Value<String?>? icd11Code,
    Value<String?>? icd10Code,
    Value<String>? description,
    Value<bool>? isPrimary,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DiagnosesCompanion(
      id: id ?? this.id,
      consultationId: consultationId ?? this.consultationId,
      patientId: patientId ?? this.patientId,
      providerId: providerId ?? this.providerId,
      facilityId: facilityId ?? this.facilityId,
      icd11Code: icd11Code ?? this.icd11Code,
      icd10Code: icd10Code ?? this.icd10Code,
      description: description ?? this.description,
      isPrimary: isPrimary ?? this.isPrimary,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (consultationId.present) {
      map['consultation_id'] = Variable<String>(consultationId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (icd11Code.present) {
      map['icd11_code'] = Variable<String>(icd11Code.value);
    }
    if (icd10Code.present) {
      map['icd10_code'] = Variable<String>(icd10Code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('DiagnosesCompanion(')
          ..write('id: $id, ')
          ..write('consultationId: $consultationId, ')
          ..write('patientId: $patientId, ')
          ..write('providerId: $providerId, ')
          ..write('facilityId: $facilityId, ')
          ..write('icd11Code: $icd11Code, ')
          ..write('icd10Code: $icd10Code, ')
          ..write('description: $description, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VitalsTable extends Vitals with TableInfo<$VitalsTable, Vital> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VitalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consultationIdMeta = const VerificationMeta(
    'consultationId',
  );
  @override
  late final GeneratedColumn<String> consultationId = GeneratedColumn<String>(
    'consultation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES consultations (id)',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureCelsiusMeta =
      const VerificationMeta('temperatureCelsius');
  @override
  late final GeneratedColumn<double> temperatureCelsius =
      GeneratedColumn<double>(
        'temperature_celsius',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pulseBpmMeta = const VerificationMeta(
    'pulseBpm',
  );
  @override
  late final GeneratedColumn<int> pulseBpm = GeneratedColumn<int>(
    'pulse_bpm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bpSystolicMeta = const VerificationMeta(
    'bpSystolic',
  );
  @override
  late final GeneratedColumn<int> bpSystolic = GeneratedColumn<int>(
    'bp_systolic',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bpDiastolicMeta = const VerificationMeta(
    'bpDiastolic',
  );
  @override
  late final GeneratedColumn<int> bpDiastolic = GeneratedColumn<int>(
    'bp_diastolic',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oxygenSaturationMeta = const VerificationMeta(
    'oxygenSaturation',
  );
  @override
  late final GeneratedColumn<int> oxygenSaturation = GeneratedColumn<int>(
    'oxygen_saturation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.pending),
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
    consultationId,
    patientId,
    facilityId,
    temperatureCelsius,
    pulseBpm,
    bpSystolic,
    bpDiastolic,
    oxygenSaturation,
    weightKg,
    heightCm,
    recordedAt,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vitals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vital> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('consultation_id')) {
      context.handle(
        _consultationIdMeta,
        consultationId.isAcceptableOrUnknown(
          data['consultation_id']!,
          _consultationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consultationIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('temperature_celsius')) {
      context.handle(
        _temperatureCelsiusMeta,
        temperatureCelsius.isAcceptableOrUnknown(
          data['temperature_celsius']!,
          _temperatureCelsiusMeta,
        ),
      );
    }
    if (data.containsKey('pulse_bpm')) {
      context.handle(
        _pulseBpmMeta,
        pulseBpm.isAcceptableOrUnknown(data['pulse_bpm']!, _pulseBpmMeta),
      );
    }
    if (data.containsKey('bp_systolic')) {
      context.handle(
        _bpSystolicMeta,
        bpSystolic.isAcceptableOrUnknown(data['bp_systolic']!, _bpSystolicMeta),
      );
    }
    if (data.containsKey('bp_diastolic')) {
      context.handle(
        _bpDiastolicMeta,
        bpDiastolic.isAcceptableOrUnknown(
          data['bp_diastolic']!,
          _bpDiastolicMeta,
        ),
      );
    }
    if (data.containsKey('oxygen_saturation')) {
      context.handle(
        _oxygenSaturationMeta,
        oxygenSaturation.isAcceptableOrUnknown(
          data['oxygen_saturation']!,
          _oxygenSaturationMeta,
        ),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  Vital map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vital(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      consultationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consultation_id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      temperatureCelsius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_celsius'],
      ),
      pulseBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pulse_bpm'],
      ),
      bpSystolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bp_systolic'],
      ),
      bpDiastolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bp_diastolic'],
      ),
      oxygenSaturation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}oxygen_saturation'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VitalsTable createAlias(String alias) {
    return $VitalsTable(attachedDatabase, alias);
  }
}

class Vital extends DataClass implements Insertable<Vital> {
  final String id;
  final String consultationId;
  final String patientId;
  final String facilityId;
  final double? temperatureCelsius;
  final int? pulseBpm;
  final int? bpSystolic;
  final int? bpDiastolic;
  final int? oxygenSaturation;
  final double? weightKg;
  final double? heightCm;
  final DateTime recordedAt;
  final String syncStatus;
  final DateTime updatedAt;
  const Vital({
    required this.id,
    required this.consultationId,
    required this.patientId,
    required this.facilityId,
    this.temperatureCelsius,
    this.pulseBpm,
    this.bpSystolic,
    this.bpDiastolic,
    this.oxygenSaturation,
    this.weightKg,
    this.heightCm,
    required this.recordedAt,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['consultation_id'] = Variable<String>(consultationId);
    map['patient_id'] = Variable<String>(patientId);
    map['facility_id'] = Variable<String>(facilityId);
    if (!nullToAbsent || temperatureCelsius != null) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius);
    }
    if (!nullToAbsent || pulseBpm != null) {
      map['pulse_bpm'] = Variable<int>(pulseBpm);
    }
    if (!nullToAbsent || bpSystolic != null) {
      map['bp_systolic'] = Variable<int>(bpSystolic);
    }
    if (!nullToAbsent || bpDiastolic != null) {
      map['bp_diastolic'] = Variable<int>(bpDiastolic);
    }
    if (!nullToAbsent || oxygenSaturation != null) {
      map['oxygen_saturation'] = Variable<int>(oxygenSaturation);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VitalsCompanion toCompanion(bool nullToAbsent) {
    return VitalsCompanion(
      id: Value(id),
      consultationId: Value(consultationId),
      patientId: Value(patientId),
      facilityId: Value(facilityId),
      temperatureCelsius: temperatureCelsius == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureCelsius),
      pulseBpm: pulseBpm == null && nullToAbsent
          ? const Value.absent()
          : Value(pulseBpm),
      bpSystolic: bpSystolic == null && nullToAbsent
          ? const Value.absent()
          : Value(bpSystolic),
      bpDiastolic: bpDiastolic == null && nullToAbsent
          ? const Value.absent()
          : Value(bpDiastolic),
      oxygenSaturation: oxygenSaturation == null && nullToAbsent
          ? const Value.absent()
          : Value(oxygenSaturation),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      recordedAt: Value(recordedAt),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory Vital.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vital(
      id: serializer.fromJson<String>(json['id']),
      consultationId: serializer.fromJson<String>(json['consultationId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      temperatureCelsius: serializer.fromJson<double?>(
        json['temperatureCelsius'],
      ),
      pulseBpm: serializer.fromJson<int?>(json['pulseBpm']),
      bpSystolic: serializer.fromJson<int?>(json['bpSystolic']),
      bpDiastolic: serializer.fromJson<int?>(json['bpDiastolic']),
      oxygenSaturation: serializer.fromJson<int?>(json['oxygenSaturation']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'consultationId': serializer.toJson<String>(consultationId),
      'patientId': serializer.toJson<String>(patientId),
      'facilityId': serializer.toJson<String>(facilityId),
      'temperatureCelsius': serializer.toJson<double?>(temperatureCelsius),
      'pulseBpm': serializer.toJson<int?>(pulseBpm),
      'bpSystolic': serializer.toJson<int?>(bpSystolic),
      'bpDiastolic': serializer.toJson<int?>(bpDiastolic),
      'oxygenSaturation': serializer.toJson<int?>(oxygenSaturation),
      'weightKg': serializer.toJson<double?>(weightKg),
      'heightCm': serializer.toJson<double?>(heightCm),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Vital copyWith({
    String? id,
    String? consultationId,
    String? patientId,
    String? facilityId,
    Value<double?> temperatureCelsius = const Value.absent(),
    Value<int?> pulseBpm = const Value.absent(),
    Value<int?> bpSystolic = const Value.absent(),
    Value<int?> bpDiastolic = const Value.absent(),
    Value<int?> oxygenSaturation = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    DateTime? recordedAt,
    String? syncStatus,
    DateTime? updatedAt,
  }) => Vital(
    id: id ?? this.id,
    consultationId: consultationId ?? this.consultationId,
    patientId: patientId ?? this.patientId,
    facilityId: facilityId ?? this.facilityId,
    temperatureCelsius: temperatureCelsius.present
        ? temperatureCelsius.value
        : this.temperatureCelsius,
    pulseBpm: pulseBpm.present ? pulseBpm.value : this.pulseBpm,
    bpSystolic: bpSystolic.present ? bpSystolic.value : this.bpSystolic,
    bpDiastolic: bpDiastolic.present ? bpDiastolic.value : this.bpDiastolic,
    oxygenSaturation: oxygenSaturation.present
        ? oxygenSaturation.value
        : this.oxygenSaturation,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    recordedAt: recordedAt ?? this.recordedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Vital copyWithCompanion(VitalsCompanion data) {
    return Vital(
      id: data.id.present ? data.id.value : this.id,
      consultationId: data.consultationId.present
          ? data.consultationId.value
          : this.consultationId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      temperatureCelsius: data.temperatureCelsius.present
          ? data.temperatureCelsius.value
          : this.temperatureCelsius,
      pulseBpm: data.pulseBpm.present ? data.pulseBpm.value : this.pulseBpm,
      bpSystolic: data.bpSystolic.present
          ? data.bpSystolic.value
          : this.bpSystolic,
      bpDiastolic: data.bpDiastolic.present
          ? data.bpDiastolic.value
          : this.bpDiastolic,
      oxygenSaturation: data.oxygenSaturation.present
          ? data.oxygenSaturation.value
          : this.oxygenSaturation,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vital(')
          ..write('id: $id, ')
          ..write('consultationId: $consultationId, ')
          ..write('patientId: $patientId, ')
          ..write('facilityId: $facilityId, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('pulseBpm: $pulseBpm, ')
          ..write('bpSystolic: $bpSystolic, ')
          ..write('bpDiastolic: $bpDiastolic, ')
          ..write('oxygenSaturation: $oxygenSaturation, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    consultationId,
    patientId,
    facilityId,
    temperatureCelsius,
    pulseBpm,
    bpSystolic,
    bpDiastolic,
    oxygenSaturation,
    weightKg,
    heightCm,
    recordedAt,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vital &&
          other.id == this.id &&
          other.consultationId == this.consultationId &&
          other.patientId == this.patientId &&
          other.facilityId == this.facilityId &&
          other.temperatureCelsius == this.temperatureCelsius &&
          other.pulseBpm == this.pulseBpm &&
          other.bpSystolic == this.bpSystolic &&
          other.bpDiastolic == this.bpDiastolic &&
          other.oxygenSaturation == this.oxygenSaturation &&
          other.weightKg == this.weightKg &&
          other.heightCm == this.heightCm &&
          other.recordedAt == this.recordedAt &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class VitalsCompanion extends UpdateCompanion<Vital> {
  final Value<String> id;
  final Value<String> consultationId;
  final Value<String> patientId;
  final Value<String> facilityId;
  final Value<double?> temperatureCelsius;
  final Value<int?> pulseBpm;
  final Value<int?> bpSystolic;
  final Value<int?> bpDiastolic;
  final Value<int?> oxygenSaturation;
  final Value<double?> weightKg;
  final Value<double?> heightCm;
  final Value<DateTime> recordedAt;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VitalsCompanion({
    this.id = const Value.absent(),
    this.consultationId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.pulseBpm = const Value.absent(),
    this.bpSystolic = const Value.absent(),
    this.bpDiastolic = const Value.absent(),
    this.oxygenSaturation = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VitalsCompanion.insert({
    required String id,
    required String consultationId,
    required String patientId,
    required String facilityId,
    this.temperatureCelsius = const Value.absent(),
    this.pulseBpm = const Value.absent(),
    this.bpSystolic = const Value.absent(),
    this.bpDiastolic = const Value.absent(),
    this.oxygenSaturation = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    required DateTime recordedAt,
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       consultationId = Value(consultationId),
       patientId = Value(patientId),
       facilityId = Value(facilityId),
       recordedAt = Value(recordedAt),
       updatedAt = Value(updatedAt);
  static Insertable<Vital> custom({
    Expression<String>? id,
    Expression<String>? consultationId,
    Expression<String>? patientId,
    Expression<String>? facilityId,
    Expression<double>? temperatureCelsius,
    Expression<int>? pulseBpm,
    Expression<int>? bpSystolic,
    Expression<int>? bpDiastolic,
    Expression<int>? oxygenSaturation,
    Expression<double>? weightKg,
    Expression<double>? heightCm,
    Expression<DateTime>? recordedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (consultationId != null) 'consultation_id': consultationId,
      if (patientId != null) 'patient_id': patientId,
      if (facilityId != null) 'facility_id': facilityId,
      if (temperatureCelsius != null) 'temperature_celsius': temperatureCelsius,
      if (pulseBpm != null) 'pulse_bpm': pulseBpm,
      if (bpSystolic != null) 'bp_systolic': bpSystolic,
      if (bpDiastolic != null) 'bp_diastolic': bpDiastolic,
      if (oxygenSaturation != null) 'oxygen_saturation': oxygenSaturation,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VitalsCompanion copyWith({
    Value<String>? id,
    Value<String>? consultationId,
    Value<String>? patientId,
    Value<String>? facilityId,
    Value<double?>? temperatureCelsius,
    Value<int?>? pulseBpm,
    Value<int?>? bpSystolic,
    Value<int?>? bpDiastolic,
    Value<int?>? oxygenSaturation,
    Value<double?>? weightKg,
    Value<double?>? heightCm,
    Value<DateTime>? recordedAt,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VitalsCompanion(
      id: id ?? this.id,
      consultationId: consultationId ?? this.consultationId,
      patientId: patientId ?? this.patientId,
      facilityId: facilityId ?? this.facilityId,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      pulseBpm: pulseBpm ?? this.pulseBpm,
      bpSystolic: bpSystolic ?? this.bpSystolic,
      bpDiastolic: bpDiastolic ?? this.bpDiastolic,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      recordedAt: recordedAt ?? this.recordedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (consultationId.present) {
      map['consultation_id'] = Variable<String>(consultationId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (temperatureCelsius.present) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius.value);
    }
    if (pulseBpm.present) {
      map['pulse_bpm'] = Variable<int>(pulseBpm.value);
    }
    if (bpSystolic.present) {
      map['bp_systolic'] = Variable<int>(bpSystolic.value);
    }
    if (bpDiastolic.present) {
      map['bp_diastolic'] = Variable<int>(bpDiastolic.value);
    }
    if (oxygenSaturation.present) {
      map['oxygen_saturation'] = Variable<int>(oxygenSaturation.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('VitalsCompanion(')
          ..write('id: $id, ')
          ..write('consultationId: $consultationId, ')
          ..write('patientId: $patientId, ')
          ..write('facilityId: $facilityId, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('pulseBpm: $pulseBpm, ')
          ..write('bpSystolic: $bpSystolic, ')
          ..write('bpDiastolic: $bpDiastolic, ')
          ..write('oxygenSaturation: $oxygenSaturation, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrescriptionsTable extends Prescriptions
    with TableInfo<$PrescriptionsTable, Prescription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrescriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consultationIdMeta = const VerificationMeta(
    'consultationId',
  );
  @override
  late final GeneratedColumn<String> consultationId = GeneratedColumn<String>(
    'consultation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES consultations (id)',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationMeta = const VerificationMeta(
    'medication',
  );
  @override
  late final GeneratedColumn<String> medication = GeneratedColumn<String>(
    'medication',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.pending),
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
    serverId,
    consultationId,
    patientId,
    providerId,
    facilityId,
    medication,
    dosage,
    frequency,
    duration,
    instructions,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prescriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prescription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('consultation_id')) {
      context.handle(
        _consultationIdMeta,
        consultationId.isAcceptableOrUnknown(
          data['consultation_id']!,
          _consultationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consultationIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('medication')) {
      context.handle(
        _medicationMeta,
        medication.isAcceptableOrUnknown(data['medication']!, _medicationMeta),
      );
    } else if (isInserting) {
      context.missing(_medicationMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  Prescription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prescription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      consultationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consultation_id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      medication: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration'],
      ),
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PrescriptionsTable createAlias(String alias) {
    return $PrescriptionsTable(attachedDatabase, alias);
  }
}

class Prescription extends DataClass implements Insertable<Prescription> {
  final String id;
  final String? serverId;
  final String consultationId;
  final String patientId;
  final String providerId;
  final String facilityId;
  final String medication;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final String? instructions;
  final String syncStatus;
  final DateTime updatedAt;
  const Prescription({
    required this.id,
    this.serverId,
    required this.consultationId,
    required this.patientId,
    required this.providerId,
    required this.facilityId,
    required this.medication,
    this.dosage,
    this.frequency,
    this.duration,
    this.instructions,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['consultation_id'] = Variable<String>(consultationId);
    map['patient_id'] = Variable<String>(patientId);
    map['provider_id'] = Variable<String>(providerId);
    map['facility_id'] = Variable<String>(facilityId);
    map['medication'] = Variable<String>(medication);
    if (!nullToAbsent || dosage != null) {
      map['dosage'] = Variable<String>(dosage);
    }
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(frequency);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<String>(duration);
    }
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PrescriptionsCompanion toCompanion(bool nullToAbsent) {
    return PrescriptionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      consultationId: Value(consultationId),
      patientId: Value(patientId),
      providerId: Value(providerId),
      facilityId: Value(facilityId),
      medication: Value(medication),
      dosage: dosage == null && nullToAbsent
          ? const Value.absent()
          : Value(dosage),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory Prescription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prescription(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      consultationId: serializer.fromJson<String>(json['consultationId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      medication: serializer.fromJson<String>(json['medication']),
      dosage: serializer.fromJson<String?>(json['dosage']),
      frequency: serializer.fromJson<String?>(json['frequency']),
      duration: serializer.fromJson<String?>(json['duration']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'consultationId': serializer.toJson<String>(consultationId),
      'patientId': serializer.toJson<String>(patientId),
      'providerId': serializer.toJson<String>(providerId),
      'facilityId': serializer.toJson<String>(facilityId),
      'medication': serializer.toJson<String>(medication),
      'dosage': serializer.toJson<String?>(dosage),
      'frequency': serializer.toJson<String?>(frequency),
      'duration': serializer.toJson<String?>(duration),
      'instructions': serializer.toJson<String?>(instructions),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Prescription copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? consultationId,
    String? patientId,
    String? providerId,
    String? facilityId,
    String? medication,
    Value<String?> dosage = const Value.absent(),
    Value<String?> frequency = const Value.absent(),
    Value<String?> duration = const Value.absent(),
    Value<String?> instructions = const Value.absent(),
    String? syncStatus,
    DateTime? updatedAt,
  }) => Prescription(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    consultationId: consultationId ?? this.consultationId,
    patientId: patientId ?? this.patientId,
    providerId: providerId ?? this.providerId,
    facilityId: facilityId ?? this.facilityId,
    medication: medication ?? this.medication,
    dosage: dosage.present ? dosage.value : this.dosage,
    frequency: frequency.present ? frequency.value : this.frequency,
    duration: duration.present ? duration.value : this.duration,
    instructions: instructions.present ? instructions.value : this.instructions,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Prescription copyWithCompanion(PrescriptionsCompanion data) {
    return Prescription(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      consultationId: data.consultationId.present
          ? data.consultationId.value
          : this.consultationId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      medication: data.medication.present
          ? data.medication.value
          : this.medication,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      duration: data.duration.present ? data.duration.value : this.duration,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prescription(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('consultationId: $consultationId, ')
          ..write('patientId: $patientId, ')
          ..write('providerId: $providerId, ')
          ..write('facilityId: $facilityId, ')
          ..write('medication: $medication, ')
          ..write('dosage: $dosage, ')
          ..write('frequency: $frequency, ')
          ..write('duration: $duration, ')
          ..write('instructions: $instructions, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    consultationId,
    patientId,
    providerId,
    facilityId,
    medication,
    dosage,
    frequency,
    duration,
    instructions,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prescription &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.consultationId == this.consultationId &&
          other.patientId == this.patientId &&
          other.providerId == this.providerId &&
          other.facilityId == this.facilityId &&
          other.medication == this.medication &&
          other.dosage == this.dosage &&
          other.frequency == this.frequency &&
          other.duration == this.duration &&
          other.instructions == this.instructions &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class PrescriptionsCompanion extends UpdateCompanion<Prescription> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> consultationId;
  final Value<String> patientId;
  final Value<String> providerId;
  final Value<String> facilityId;
  final Value<String> medication;
  final Value<String?> dosage;
  final Value<String?> frequency;
  final Value<String?> duration;
  final Value<String?> instructions;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PrescriptionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.consultationId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.medication = const Value.absent(),
    this.dosage = const Value.absent(),
    this.frequency = const Value.absent(),
    this.duration = const Value.absent(),
    this.instructions = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrescriptionsCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String consultationId,
    required String patientId,
    required String providerId,
    required String facilityId,
    required String medication,
    this.dosage = const Value.absent(),
    this.frequency = const Value.absent(),
    this.duration = const Value.absent(),
    this.instructions = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       consultationId = Value(consultationId),
       patientId = Value(patientId),
       providerId = Value(providerId),
       facilityId = Value(facilityId),
       medication = Value(medication),
       updatedAt = Value(updatedAt);
  static Insertable<Prescription> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? consultationId,
    Expression<String>? patientId,
    Expression<String>? providerId,
    Expression<String>? facilityId,
    Expression<String>? medication,
    Expression<String>? dosage,
    Expression<String>? frequency,
    Expression<String>? duration,
    Expression<String>? instructions,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (consultationId != null) 'consultation_id': consultationId,
      if (patientId != null) 'patient_id': patientId,
      if (providerId != null) 'provider_id': providerId,
      if (facilityId != null) 'facility_id': facilityId,
      if (medication != null) 'medication': medication,
      if (dosage != null) 'dosage': dosage,
      if (frequency != null) 'frequency': frequency,
      if (duration != null) 'duration': duration,
      if (instructions != null) 'instructions': instructions,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrescriptionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? consultationId,
    Value<String>? patientId,
    Value<String>? providerId,
    Value<String>? facilityId,
    Value<String>? medication,
    Value<String?>? dosage,
    Value<String?>? frequency,
    Value<String?>? duration,
    Value<String?>? instructions,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PrescriptionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      consultationId: consultationId ?? this.consultationId,
      patientId: patientId ?? this.patientId,
      providerId: providerId ?? this.providerId,
      facilityId: facilityId ?? this.facilityId,
      medication: medication ?? this.medication,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (consultationId.present) {
      map['consultation_id'] = Variable<String>(consultationId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (medication.present) {
      map['medication'] = Variable<String>(medication.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (duration.present) {
      map['duration'] = Variable<String>(duration.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('PrescriptionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('consultationId: $consultationId, ')
          ..write('patientId: $patientId, ')
          ..write('providerId: $providerId, ')
          ..write('facilityId: $facilityId, ')
          ..write('medication: $medication, ')
          ..write('dosage: $dosage, ')
          ..write('frequency: $frequency, ')
          ..write('duration: $duration, ')
          ..write('instructions: $instructions, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
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
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payloadJson,
    retryCount,
    createdAt,
    lastAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payloadJson;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  const SyncQueueData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.retryCount,
    required this.createdAt,
    this.lastAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? operation,
    String? payloadJson,
    int? retryCount,
    DateTime? createdAt,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payloadJson,
    retryCount,
    createdAt,
    lastAttemptAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    required String payloadJson,
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
    this.lastAttemptAt = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastAttemptAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entityType, facilityId, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, facilityId};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String entityType;
  final String facilityId;
  final DateTime lastSyncedAt;
  const SyncCursor({
    required this.entityType,
    required this.facilityId,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['facility_id'] = Variable<String>(facilityId);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      entityType: Value(entityType),
      facilityId: Value(facilityId),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      entityType: serializer.fromJson<String>(json['entityType']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'facilityId': serializer.toJson<String>(facilityId),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
    };
  }

  SyncCursor copyWith({
    String? entityType,
    String? facilityId,
    DateTime? lastSyncedAt,
  }) => SyncCursor(
    entityType: entityType ?? this.entityType,
    facilityId: facilityId ?? this.facilityId,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('entityType: $entityType, ')
          ..write('facilityId: $facilityId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, facilityId, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.entityType == this.entityType &&
          other.facilityId == this.facilityId &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> entityType;
  final Value<String> facilityId;
  final Value<DateTime> lastSyncedAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.entityType = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String entityType,
    required String facilityId,
    required DateTime lastSyncedAt,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       facilityId = Value(facilityId),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<SyncCursor> custom({
    Expression<String>? entityType,
    Expression<String>? facilityId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (facilityId != null) 'facility_id': facilityId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? entityType,
    Value<String>? facilityId,
    Value<DateTime>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      entityType: entityType ?? this.entityType,
      facilityId: facilityId ?? this.facilityId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('entityType: $entityType, ')
          ..write('facilityId: $facilityId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeatureFlagsTable extends FeatureFlags
    with TableInfo<$FeatureFlagsTable, FeatureFlag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeatureFlagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
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
  List<GeneratedColumn> get $columns => [key, enabled, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feature_flags';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeatureFlag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
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
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  FeatureFlag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeatureFlag(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FeatureFlagsTable createAlias(String alias) {
    return $FeatureFlagsTable(attachedDatabase, alias);
  }
}

class FeatureFlag extends DataClass implements Insertable<FeatureFlag> {
  final String key;
  final bool enabled;
  final DateTime updatedAt;
  const FeatureFlag({
    required this.key,
    required this.enabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['enabled'] = Variable<bool>(enabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FeatureFlagsCompanion toCompanion(bool nullToAbsent) {
    return FeatureFlagsCompanion(
      key: Value(key),
      enabled: Value(enabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeatureFlag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeatureFlag(
      key: serializer.fromJson<String>(json['key']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'enabled': serializer.toJson<bool>(enabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FeatureFlag copyWith({String? key, bool? enabled, DateTime? updatedAt}) =>
      FeatureFlag(
        key: key ?? this.key,
        enabled: enabled ?? this.enabled,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FeatureFlag copyWithCompanion(FeatureFlagsCompanion data) {
    return FeatureFlag(
      key: data.key.present ? data.key.value : this.key,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeatureFlag(')
          ..write('key: $key, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, enabled, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeatureFlag &&
          other.key == this.key &&
          other.enabled == this.enabled &&
          other.updatedAt == this.updatedAt);
}

class FeatureFlagsCompanion extends UpdateCompanion<FeatureFlag> {
  final Value<String> key;
  final Value<bool> enabled;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FeatureFlagsCompanion({
    this.key = const Value.absent(),
    this.enabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeatureFlagsCompanion.insert({
    required String key,
    this.enabled = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       updatedAt = Value(updatedAt);
  static Insertable<FeatureFlag> custom({
    Expression<String>? key,
    Expression<bool>? enabled,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (enabled != null) 'enabled': enabled,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeatureFlagsCompanion copyWith({
    Value<String>? key,
    Value<bool>? enabled,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FeatureFlagsCompanion(
      key: key ?? this.key,
      enabled: enabled ?? this.enabled,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
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
    return (StringBuffer('FeatureFlagsCompanion(')
          ..write('key: $key, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $Icd11CodesTable extends Icd11Codes
    with TableInfo<$Icd11CodesTable, Icd11Code> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $Icd11CodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _useCountMeta = const VerificationMeta(
    'useCount',
  );
  @override
  late final GeneratedColumn<int> useCount = GeneratedColumn<int>(
    'use_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    description,
    isFavorite,
    useCount,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'icd11_codes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Icd11Code> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('use_count')) {
      context.handle(
        _useCountMeta,
        useCount.isAcceptableOrUnknown(data['use_count']!, _useCountMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Icd11Code map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Icd11Code(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      useCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}use_count'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
    );
  }

  @override
  $Icd11CodesTable createAlias(String alias) {
    return $Icd11CodesTable(attachedDatabase, alias);
  }
}

class Icd11Code extends DataClass implements Insertable<Icd11Code> {
  final String code;
  final String description;
  final bool isFavorite;
  final int useCount;
  final DateTime? lastUsedAt;
  const Icd11Code({
    required this.code,
    required this.description,
    required this.isFavorite,
    required this.useCount,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['description'] = Variable<String>(description);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['use_count'] = Variable<int>(useCount);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  Icd11CodesCompanion toCompanion(bool nullToAbsent) {
    return Icd11CodesCompanion(
      code: Value(code),
      description: Value(description),
      isFavorite: Value(isFavorite),
      useCount: Value(useCount),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory Icd11Code.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Icd11Code(
      code: serializer.fromJson<String>(json['code']),
      description: serializer.fromJson<String>(json['description']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      useCount: serializer.fromJson<int>(json['useCount']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'description': serializer.toJson<String>(description),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'useCount': serializer.toJson<int>(useCount),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  Icd11Code copyWith({
    String? code,
    String? description,
    bool? isFavorite,
    int? useCount,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => Icd11Code(
    code: code ?? this.code,
    description: description ?? this.description,
    isFavorite: isFavorite ?? this.isFavorite,
    useCount: useCount ?? this.useCount,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  Icd11Code copyWithCompanion(Icd11CodesCompanion data) {
    return Icd11Code(
      code: data.code.present ? data.code.value : this.code,
      description: data.description.present
          ? data.description.value
          : this.description,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      useCount: data.useCount.present ? data.useCount.value : this.useCount,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Icd11Code(')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('useCount: $useCount, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, description, isFavorite, useCount, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Icd11Code &&
          other.code == this.code &&
          other.description == this.description &&
          other.isFavorite == this.isFavorite &&
          other.useCount == this.useCount &&
          other.lastUsedAt == this.lastUsedAt);
}

class Icd11CodesCompanion extends UpdateCompanion<Icd11Code> {
  final Value<String> code;
  final Value<String> description;
  final Value<bool> isFavorite;
  final Value<int> useCount;
  final Value<DateTime?> lastUsedAt;
  final Value<int> rowid;
  const Icd11CodesCompanion({
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.useCount = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  Icd11CodesCompanion.insert({
    required String code,
    required String description,
    this.isFavorite = const Value.absent(),
    this.useCount = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       description = Value(description);
  static Insertable<Icd11Code> custom({
    Expression<String>? code,
    Expression<String>? description,
    Expression<bool>? isFavorite,
    Expression<int>? useCount,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (useCount != null) 'use_count': useCount,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  Icd11CodesCompanion copyWith({
    Value<String>? code,
    Value<String>? description,
    Value<bool>? isFavorite,
    Value<int>? useCount,
    Value<DateTime?>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return Icd11CodesCompanion(
      code: code ?? this.code,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      useCount: useCount ?? this.useCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (useCount.present) {
      map['use_count'] = Variable<int>(useCount.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('Icd11CodesCompanion(')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('useCount: $useCount, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _defaultDosageMeta = const VerificationMeta(
    'defaultDosage',
  );
  @override
  late final GeneratedColumn<String> defaultDosage = GeneratedColumn<String>(
    'default_dosage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, formulation, defaultDosage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('default_dosage')) {
      context.handle(
        _defaultDosageMeta,
        defaultDosage.isAcceptableOrUnknown(
          data['default_dosage']!,
          _defaultDosageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      formulation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formulation'],
      ),
      defaultDosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_dosage'],
      ),
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final String id;
  final String name;
  final String? formulation;
  final String? defaultDosage;
  const Medication({
    required this.id,
    required this.name,
    this.formulation,
    this.defaultDosage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || formulation != null) {
      map['formulation'] = Variable<String>(formulation);
    }
    if (!nullToAbsent || defaultDosage != null) {
      map['default_dosage'] = Variable<String>(defaultDosage);
    }
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      formulation: formulation == null && nullToAbsent
          ? const Value.absent()
          : Value(formulation),
      defaultDosage: defaultDosage == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultDosage),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      formulation: serializer.fromJson<String?>(json['formulation']),
      defaultDosage: serializer.fromJson<String?>(json['defaultDosage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'formulation': serializer.toJson<String?>(formulation),
      'defaultDosage': serializer.toJson<String?>(defaultDosage),
    };
  }

  Medication copyWith({
    String? id,
    String? name,
    Value<String?> formulation = const Value.absent(),
    Value<String?> defaultDosage = const Value.absent(),
  }) => Medication(
    id: id ?? this.id,
    name: name ?? this.name,
    formulation: formulation.present ? formulation.value : this.formulation,
    defaultDosage: defaultDosage.present
        ? defaultDosage.value
        : this.defaultDosage,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      formulation: data.formulation.present
          ? data.formulation.value
          : this.formulation,
      defaultDosage: data.defaultDosage.present
          ? data.defaultDosage.value
          : this.defaultDosage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('formulation: $formulation, ')
          ..write('defaultDosage: $defaultDosage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, formulation, defaultDosage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.name == this.name &&
          other.formulation == this.formulation &&
          other.defaultDosage == this.defaultDosage);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> formulation;
  final Value<String?> defaultDosage;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.formulation = const Value.absent(),
    this.defaultDosage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    required String id,
    required String name,
    this.formulation = const Value.absent(),
    this.defaultDosage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Medication> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? formulation,
    Expression<String>? defaultDosage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (formulation != null) 'formulation': formulation,
      if (defaultDosage != null) 'default_dosage': defaultDosage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? formulation,
    Value<String?>? defaultDosage,
    Value<int>? rowid,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      formulation: formulation ?? this.formulation,
      defaultDosage: defaultDosage ?? this.defaultDosage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (formulation.present) {
      map['formulation'] = Variable<String>(formulation.value);
    }
    if (defaultDosage.present) {
      map['default_dosage'] = Variable<String>(defaultDosage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('formulation: $formulation, ')
          ..write('defaultDosage: $defaultDosage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EdlizRecommendationsTable extends EdlizRecommendations
    with TableInfo<$EdlizRecommendationsTable, EdlizRecommendation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EdlizRecommendationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _icd11CodeMeta = const VerificationMeta(
    'icd11Code',
  );
  @override
  late final GeneratedColumn<String> icd11Code = GeneratedColumn<String>(
    'icd11_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstLineMeta = const VerificationMeta(
    'firstLine',
  );
  @override
  late final GeneratedColumn<String> firstLine = GeneratedColumn<String>(
    'first_line',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alternativeMeta = const VerificationMeta(
    'alternative',
  );
  @override
  late final GeneratedColumn<String> alternative = GeneratedColumn<String>(
    'alternative',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    icd11Code,
    firstLine,
    alternative,
    dosage,
    formulation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'edliz_recommendations';
  @override
  VerificationContext validateIntegrity(
    Insertable<EdlizRecommendation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('icd11_code')) {
      context.handle(
        _icd11CodeMeta,
        icd11Code.isAcceptableOrUnknown(data['icd11_code']!, _icd11CodeMeta),
      );
    } else if (isInserting) {
      context.missing(_icd11CodeMeta);
    }
    if (data.containsKey('first_line')) {
      context.handle(
        _firstLineMeta,
        firstLine.isAcceptableOrUnknown(data['first_line']!, _firstLineMeta),
      );
    } else if (isInserting) {
      context.missing(_firstLineMeta);
    }
    if (data.containsKey('alternative')) {
      context.handle(
        _alternativeMeta,
        alternative.isAcceptableOrUnknown(
          data['alternative']!,
          _alternativeMeta,
        ),
      );
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EdlizRecommendation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EdlizRecommendation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      icd11Code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icd11_code'],
      )!,
      firstLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_line'],
      )!,
      alternative: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternative'],
      ),
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      ),
      formulation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formulation'],
      ),
    );
  }

  @override
  $EdlizRecommendationsTable createAlias(String alias) {
    return $EdlizRecommendationsTable(attachedDatabase, alias);
  }
}

class EdlizRecommendation extends DataClass
    implements Insertable<EdlizRecommendation> {
  final String id;
  final String icd11Code;
  final String firstLine;
  final String? alternative;
  final String? dosage;
  final String? formulation;
  const EdlizRecommendation({
    required this.id,
    required this.icd11Code,
    required this.firstLine,
    this.alternative,
    this.dosage,
    this.formulation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['icd11_code'] = Variable<String>(icd11Code);
    map['first_line'] = Variable<String>(firstLine);
    if (!nullToAbsent || alternative != null) {
      map['alternative'] = Variable<String>(alternative);
    }
    if (!nullToAbsent || dosage != null) {
      map['dosage'] = Variable<String>(dosage);
    }
    if (!nullToAbsent || formulation != null) {
      map['formulation'] = Variable<String>(formulation);
    }
    return map;
  }

  EdlizRecommendationsCompanion toCompanion(bool nullToAbsent) {
    return EdlizRecommendationsCompanion(
      id: Value(id),
      icd11Code: Value(icd11Code),
      firstLine: Value(firstLine),
      alternative: alternative == null && nullToAbsent
          ? const Value.absent()
          : Value(alternative),
      dosage: dosage == null && nullToAbsent
          ? const Value.absent()
          : Value(dosage),
      formulation: formulation == null && nullToAbsent
          ? const Value.absent()
          : Value(formulation),
    );
  }

  factory EdlizRecommendation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EdlizRecommendation(
      id: serializer.fromJson<String>(json['id']),
      icd11Code: serializer.fromJson<String>(json['icd11Code']),
      firstLine: serializer.fromJson<String>(json['firstLine']),
      alternative: serializer.fromJson<String?>(json['alternative']),
      dosage: serializer.fromJson<String?>(json['dosage']),
      formulation: serializer.fromJson<String?>(json['formulation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'icd11Code': serializer.toJson<String>(icd11Code),
      'firstLine': serializer.toJson<String>(firstLine),
      'alternative': serializer.toJson<String?>(alternative),
      'dosage': serializer.toJson<String?>(dosage),
      'formulation': serializer.toJson<String?>(formulation),
    };
  }

  EdlizRecommendation copyWith({
    String? id,
    String? icd11Code,
    String? firstLine,
    Value<String?> alternative = const Value.absent(),
    Value<String?> dosage = const Value.absent(),
    Value<String?> formulation = const Value.absent(),
  }) => EdlizRecommendation(
    id: id ?? this.id,
    icd11Code: icd11Code ?? this.icd11Code,
    firstLine: firstLine ?? this.firstLine,
    alternative: alternative.present ? alternative.value : this.alternative,
    dosage: dosage.present ? dosage.value : this.dosage,
    formulation: formulation.present ? formulation.value : this.formulation,
  );
  EdlizRecommendation copyWithCompanion(EdlizRecommendationsCompanion data) {
    return EdlizRecommendation(
      id: data.id.present ? data.id.value : this.id,
      icd11Code: data.icd11Code.present ? data.icd11Code.value : this.icd11Code,
      firstLine: data.firstLine.present ? data.firstLine.value : this.firstLine,
      alternative: data.alternative.present
          ? data.alternative.value
          : this.alternative,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      formulation: data.formulation.present
          ? data.formulation.value
          : this.formulation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EdlizRecommendation(')
          ..write('id: $id, ')
          ..write('icd11Code: $icd11Code, ')
          ..write('firstLine: $firstLine, ')
          ..write('alternative: $alternative, ')
          ..write('dosage: $dosage, ')
          ..write('formulation: $formulation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, icd11Code, firstLine, alternative, dosage, formulation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EdlizRecommendation &&
          other.id == this.id &&
          other.icd11Code == this.icd11Code &&
          other.firstLine == this.firstLine &&
          other.alternative == this.alternative &&
          other.dosage == this.dosage &&
          other.formulation == this.formulation);
}

class EdlizRecommendationsCompanion
    extends UpdateCompanion<EdlizRecommendation> {
  final Value<String> id;
  final Value<String> icd11Code;
  final Value<String> firstLine;
  final Value<String?> alternative;
  final Value<String?> dosage;
  final Value<String?> formulation;
  final Value<int> rowid;
  const EdlizRecommendationsCompanion({
    this.id = const Value.absent(),
    this.icd11Code = const Value.absent(),
    this.firstLine = const Value.absent(),
    this.alternative = const Value.absent(),
    this.dosage = const Value.absent(),
    this.formulation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EdlizRecommendationsCompanion.insert({
    required String id,
    required String icd11Code,
    required String firstLine,
    this.alternative = const Value.absent(),
    this.dosage = const Value.absent(),
    this.formulation = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       icd11Code = Value(icd11Code),
       firstLine = Value(firstLine);
  static Insertable<EdlizRecommendation> custom({
    Expression<String>? id,
    Expression<String>? icd11Code,
    Expression<String>? firstLine,
    Expression<String>? alternative,
    Expression<String>? dosage,
    Expression<String>? formulation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (icd11Code != null) 'icd11_code': icd11Code,
      if (firstLine != null) 'first_line': firstLine,
      if (alternative != null) 'alternative': alternative,
      if (dosage != null) 'dosage': dosage,
      if (formulation != null) 'formulation': formulation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EdlizRecommendationsCompanion copyWith({
    Value<String>? id,
    Value<String>? icd11Code,
    Value<String>? firstLine,
    Value<String?>? alternative,
    Value<String?>? dosage,
    Value<String?>? formulation,
    Value<int>? rowid,
  }) {
    return EdlizRecommendationsCompanion(
      id: id ?? this.id,
      icd11Code: icd11Code ?? this.icd11Code,
      firstLine: firstLine ?? this.firstLine,
      alternative: alternative ?? this.alternative,
      dosage: dosage ?? this.dosage,
      formulation: formulation ?? this.formulation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (icd11Code.present) {
      map['icd11_code'] = Variable<String>(icd11Code.value);
    }
    if (firstLine.present) {
      map['first_line'] = Variable<String>(firstLine.value);
    }
    if (alternative.present) {
      map['alternative'] = Variable<String>(alternative.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (formulation.present) {
      map['formulation'] = Variable<String>(formulation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EdlizRecommendationsCompanion(')
          ..write('id: $id, ')
          ..write('icd11Code: $icd11Code, ')
          ..write('firstLine: $firstLine, ')
          ..write('alternative: $alternative, ')
          ..write('dosage: $dosage, ')
          ..write('formulation: $formulation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
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
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    action,
    subjectId,
    facilityId,
    providerId,
    detailsJson,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      ),
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String action;
  final String? subjectId;
  final String? facilityId;
  final String? providerId;
  final String detailsJson;
  final DateTime createdAt;
  final bool synced;
  const AuditLog({
    required this.id,
    required this.action,
    this.subjectId,
    this.facilityId,
    this.providerId,
    required this.detailsJson,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    if (!nullToAbsent || facilityId != null) {
      map['facility_id'] = Variable<String>(facilityId);
    }
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    map['details_json'] = Variable<String>(detailsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      action: Value(action),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      facilityId: facilityId == null && nullToAbsent
          ? const Value.absent()
          : Value(facilityId),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      detailsJson: Value(detailsJson),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      facilityId: serializer.fromJson<String?>(json['facilityId']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      detailsJson: serializer.fromJson<String>(json['detailsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'action': serializer.toJson<String>(action),
      'subjectId': serializer.toJson<String?>(subjectId),
      'facilityId': serializer.toJson<String?>(facilityId),
      'providerId': serializer.toJson<String?>(providerId),
      'detailsJson': serializer.toJson<String>(detailsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  AuditLog copyWith({
    String? id,
    String? action,
    Value<String?> subjectId = const Value.absent(),
    Value<String?> facilityId = const Value.absent(),
    Value<String?> providerId = const Value.absent(),
    String? detailsJson,
    DateTime? createdAt,
    bool? synced,
  }) => AuditLog(
    id: id ?? this.id,
    action: action ?? this.action,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    facilityId: facilityId.present ? facilityId.value : this.facilityId,
    providerId: providerId.present ? providerId.value : this.providerId,
    detailsJson: detailsJson ?? this.detailsJson,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('subjectId: $subjectId, ')
          ..write('facilityId: $facilityId, ')
          ..write('providerId: $providerId, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    action,
    subjectId,
    facilityId,
    providerId,
    detailsJson,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.action == this.action &&
          other.subjectId == this.subjectId &&
          other.facilityId == this.facilityId &&
          other.providerId == this.providerId &&
          other.detailsJson == this.detailsJson &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> action;
  final Value<String?> subjectId;
  final Value<String?> facilityId;
  final Value<String?> providerId;
  final Value<String> detailsJson;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required String action,
    this.subjectId = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.detailsJson = const Value.absent(),
    required DateTime createdAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       action = Value(action),
       createdAt = Value(createdAt);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? action,
    Expression<String>? subjectId,
    Expression<String>? facilityId,
    Expression<String>? providerId,
    Expression<String>? detailsJson,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (subjectId != null) 'subject_id': subjectId,
      if (facilityId != null) 'facility_id': facilityId,
      if (providerId != null) 'provider_id': providerId,
      if (detailsJson != null) 'details_json': detailsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? action,
    Value<String?>? subjectId,
    Value<String?>? facilityId,
    Value<String?>? providerId,
    Value<String>? detailsJson,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      subjectId: subjectId ?? this.subjectId,
      facilityId: facilityId ?? this.facilityId,
      providerId: providerId ?? this.providerId,
      detailsJson: detailsJson ?? this.detailsJson,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('subjectId: $subjectId, ')
          ..write('facilityId: $facilityId, ')
          ..write('providerId: $providerId, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InsuranceClaimsTable extends InsuranceClaims
    with TableInfo<$InsuranceClaimsTable, InsuranceClaim> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsuranceClaimsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facilities (id)',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payerKeyMeta = const VerificationMeta(
    'payerKey',
  );
  @override
  late final GeneratedColumn<String> payerKey = GeneratedColumn<String>(
    'payer_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncMetadata.synced),
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
    serverId,
    facilityId,
    patientId,
    providerId,
    payerKey,
    status,
    amount,
    amountPaid,
    submittedAt,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insurance_claims';
  @override
  VerificationContext validateIntegrity(
    Insertable<InsuranceClaim> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('payer_key')) {
      context.handle(
        _payerKeyMeta,
        payerKey.isAcceptableOrUnknown(data['payer_key']!, _payerKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_payerKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  InsuranceClaim map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsuranceClaim(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      payerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payer_key'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InsuranceClaimsTable createAlias(String alias) {
    return $InsuranceClaimsTable(attachedDatabase, alias);
  }
}

class InsuranceClaim extends DataClass implements Insertable<InsuranceClaim> {
  final String id;
  final String? serverId;
  final String facilityId;
  final String patientId;
  final String providerId;
  final String payerKey;
  final String status;
  final double amount;
  final double amountPaid;
  final DateTime? submittedAt;
  final String syncStatus;
  final DateTime updatedAt;
  const InsuranceClaim({
    required this.id,
    this.serverId,
    required this.facilityId,
    required this.patientId,
    required this.providerId,
    required this.payerKey,
    required this.status,
    required this.amount,
    required this.amountPaid,
    this.submittedAt,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['facility_id'] = Variable<String>(facilityId);
    map['patient_id'] = Variable<String>(patientId);
    map['provider_id'] = Variable<String>(providerId);
    map['payer_key'] = Variable<String>(payerKey);
    map['status'] = Variable<String>(status);
    map['amount'] = Variable<double>(amount);
    map['amount_paid'] = Variable<double>(amountPaid);
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<DateTime>(submittedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InsuranceClaimsCompanion toCompanion(bool nullToAbsent) {
    return InsuranceClaimsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      facilityId: Value(facilityId),
      patientId: Value(patientId),
      providerId: Value(providerId),
      payerKey: Value(payerKey),
      status: Value(status),
      amount: Value(amount),
      amountPaid: Value(amountPaid),
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory InsuranceClaim.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsuranceClaim(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      payerKey: serializer.fromJson<String>(json['payerKey']),
      status: serializer.fromJson<String>(json['status']),
      amount: serializer.fromJson<double>(json['amount']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      submittedAt: serializer.fromJson<DateTime?>(json['submittedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'facilityId': serializer.toJson<String>(facilityId),
      'patientId': serializer.toJson<String>(patientId),
      'providerId': serializer.toJson<String>(providerId),
      'payerKey': serializer.toJson<String>(payerKey),
      'status': serializer.toJson<String>(status),
      'amount': serializer.toJson<double>(amount),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'submittedAt': serializer.toJson<DateTime?>(submittedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InsuranceClaim copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? facilityId,
    String? patientId,
    String? providerId,
    String? payerKey,
    String? status,
    double? amount,
    double? amountPaid,
    Value<DateTime?> submittedAt = const Value.absent(),
    String? syncStatus,
    DateTime? updatedAt,
  }) => InsuranceClaim(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    facilityId: facilityId ?? this.facilityId,
    patientId: patientId ?? this.patientId,
    providerId: providerId ?? this.providerId,
    payerKey: payerKey ?? this.payerKey,
    status: status ?? this.status,
    amount: amount ?? this.amount,
    amountPaid: amountPaid ?? this.amountPaid,
    submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  InsuranceClaim copyWithCompanion(InsuranceClaimsCompanion data) {
    return InsuranceClaim(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      payerKey: data.payerKey.present ? data.payerKey.value : this.payerKey,
      status: data.status.present ? data.status.value : this.status,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsuranceClaim(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('facilityId: $facilityId, ')
          ..write('patientId: $patientId, ')
          ..write('providerId: $providerId, ')
          ..write('payerKey: $payerKey, ')
          ..write('status: $status, ')
          ..write('amount: $amount, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    facilityId,
    patientId,
    providerId,
    payerKey,
    status,
    amount,
    amountPaid,
    submittedAt,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsuranceClaim &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.facilityId == this.facilityId &&
          other.patientId == this.patientId &&
          other.providerId == this.providerId &&
          other.payerKey == this.payerKey &&
          other.status == this.status &&
          other.amount == this.amount &&
          other.amountPaid == this.amountPaid &&
          other.submittedAt == this.submittedAt &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class InsuranceClaimsCompanion extends UpdateCompanion<InsuranceClaim> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> facilityId;
  final Value<String> patientId;
  final Value<String> providerId;
  final Value<String> payerKey;
  final Value<String> status;
  final Value<double> amount;
  final Value<double> amountPaid;
  final Value<DateTime?> submittedAt;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InsuranceClaimsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.payerKey = const Value.absent(),
    this.status = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InsuranceClaimsCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String facilityId,
    required String patientId,
    required String providerId,
    required String payerKey,
    required String status,
    this.amount = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityId = Value(facilityId),
       patientId = Value(patientId),
       providerId = Value(providerId),
       payerKey = Value(payerKey),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<InsuranceClaim> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? facilityId,
    Expression<String>? patientId,
    Expression<String>? providerId,
    Expression<String>? payerKey,
    Expression<String>? status,
    Expression<double>? amount,
    Expression<double>? amountPaid,
    Expression<DateTime>? submittedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (facilityId != null) 'facility_id': facilityId,
      if (patientId != null) 'patient_id': patientId,
      if (providerId != null) 'provider_id': providerId,
      if (payerKey != null) 'payer_key': payerKey,
      if (status != null) 'status': status,
      if (amount != null) 'amount': amount,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InsuranceClaimsCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? facilityId,
    Value<String>? patientId,
    Value<String>? providerId,
    Value<String>? payerKey,
    Value<String>? status,
    Value<double>? amount,
    Value<double>? amountPaid,
    Value<DateTime?>? submittedAt,
    Value<String>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return InsuranceClaimsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      facilityId: facilityId ?? this.facilityId,
      patientId: patientId ?? this.patientId,
      providerId: providerId ?? this.providerId,
      payerKey: payerKey ?? this.payerKey,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      amountPaid: amountPaid ?? this.amountPaid,
      submittedAt: submittedAt ?? this.submittedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (payerKey.present) {
      map['payer_key'] = Variable<String>(payerKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('InsuranceClaimsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('facilityId: $facilityId, ')
          ..write('patientId: $patientId, ')
          ..write('providerId: $providerId, ')
          ..write('payerKey: $payerKey, ')
          ..write('status: $status, ')
          ..write('amount: $amount, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClinicalTasksTable extends ClinicalTasks
    with TableInfo<$ClinicalTasksTable, ClinicalTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClinicalTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facilities (id)',
    ),
  );
  static const VerificationMeta _assigneeIdMeta = const VerificationMeta(
    'assigneeId',
  );
  @override
  late final GeneratedColumn<String> assigneeId = GeneratedColumn<String>(
    'assignee_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskTypeMeta = const VerificationMeta(
    'taskType',
  );
  @override
  late final GeneratedColumn<String> taskType = GeneratedColumn<String>(
    'task_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    facilityId,
    assigneeId,
    patientId,
    title,
    taskType,
    status,
    dueAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clinical_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClinicalTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('assignee_id')) {
      context.handle(
        _assigneeIdMeta,
        assigneeId.isAcceptableOrUnknown(data['assignee_id']!, _assigneeIdMeta),
      );
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('task_type')) {
      context.handle(
        _taskTypeMeta,
        taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
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
  ClinicalTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClinicalTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      assigneeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignee_id'],
      ),
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      taskType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClinicalTasksTable createAlias(String alias) {
    return $ClinicalTasksTable(attachedDatabase, alias);
  }
}

class ClinicalTask extends DataClass implements Insertable<ClinicalTask> {
  final String id;
  final String facilityId;
  final String? assigneeId;
  final String? patientId;
  final String title;
  final String taskType;
  final String status;
  final DateTime? dueAt;
  final DateTime createdAt;
  const ClinicalTask({
    required this.id,
    required this.facilityId,
    this.assigneeId,
    this.patientId,
    required this.title,
    required this.taskType,
    required this.status,
    this.dueAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['facility_id'] = Variable<String>(facilityId);
    if (!nullToAbsent || assigneeId != null) {
      map['assignee_id'] = Variable<String>(assigneeId);
    }
    if (!nullToAbsent || patientId != null) {
      map['patient_id'] = Variable<String>(patientId);
    }
    map['title'] = Variable<String>(title);
    map['task_type'] = Variable<String>(taskType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClinicalTasksCompanion toCompanion(bool nullToAbsent) {
    return ClinicalTasksCompanion(
      id: Value(id),
      facilityId: Value(facilityId),
      assigneeId: assigneeId == null && nullToAbsent
          ? const Value.absent()
          : Value(assigneeId),
      patientId: patientId == null && nullToAbsent
          ? const Value.absent()
          : Value(patientId),
      title: Value(title),
      taskType: Value(taskType),
      status: Value(status),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      createdAt: Value(createdAt),
    );
  }

  factory ClinicalTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClinicalTask(
      id: serializer.fromJson<String>(json['id']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      assigneeId: serializer.fromJson<String?>(json['assigneeId']),
      patientId: serializer.fromJson<String?>(json['patientId']),
      title: serializer.fromJson<String>(json['title']),
      taskType: serializer.fromJson<String>(json['taskType']),
      status: serializer.fromJson<String>(json['status']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'facilityId': serializer.toJson<String>(facilityId),
      'assigneeId': serializer.toJson<String?>(assigneeId),
      'patientId': serializer.toJson<String?>(patientId),
      'title': serializer.toJson<String>(title),
      'taskType': serializer.toJson<String>(taskType),
      'status': serializer.toJson<String>(status),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ClinicalTask copyWith({
    String? id,
    String? facilityId,
    Value<String?> assigneeId = const Value.absent(),
    Value<String?> patientId = const Value.absent(),
    String? title,
    String? taskType,
    String? status,
    Value<DateTime?> dueAt = const Value.absent(),
    DateTime? createdAt,
  }) => ClinicalTask(
    id: id ?? this.id,
    facilityId: facilityId ?? this.facilityId,
    assigneeId: assigneeId.present ? assigneeId.value : this.assigneeId,
    patientId: patientId.present ? patientId.value : this.patientId,
    title: title ?? this.title,
    taskType: taskType ?? this.taskType,
    status: status ?? this.status,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    createdAt: createdAt ?? this.createdAt,
  );
  ClinicalTask copyWithCompanion(ClinicalTasksCompanion data) {
    return ClinicalTask(
      id: data.id.present ? data.id.value : this.id,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      assigneeId: data.assigneeId.present
          ? data.assigneeId.value
          : this.assigneeId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      title: data.title.present ? data.title.value : this.title,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      status: data.status.present ? data.status.value : this.status,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalTask(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('assigneeId: $assigneeId, ')
          ..write('patientId: $patientId, ')
          ..write('title: $title, ')
          ..write('taskType: $taskType, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    facilityId,
    assigneeId,
    patientId,
    title,
    taskType,
    status,
    dueAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClinicalTask &&
          other.id == this.id &&
          other.facilityId == this.facilityId &&
          other.assigneeId == this.assigneeId &&
          other.patientId == this.patientId &&
          other.title == this.title &&
          other.taskType == this.taskType &&
          other.status == this.status &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt);
}

class ClinicalTasksCompanion extends UpdateCompanion<ClinicalTask> {
  final Value<String> id;
  final Value<String> facilityId;
  final Value<String?> assigneeId;
  final Value<String?> patientId;
  final Value<String> title;
  final Value<String> taskType;
  final Value<String> status;
  final Value<DateTime?> dueAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ClinicalTasksCompanion({
    this.id = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.assigneeId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.title = const Value.absent(),
    this.taskType = const Value.absent(),
    this.status = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClinicalTasksCompanion.insert({
    required String id,
    required String facilityId,
    this.assigneeId = const Value.absent(),
    this.patientId = const Value.absent(),
    required String title,
    required String taskType,
    this.status = const Value.absent(),
    this.dueAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityId = Value(facilityId),
       title = Value(title),
       taskType = Value(taskType),
       createdAt = Value(createdAt);
  static Insertable<ClinicalTask> custom({
    Expression<String>? id,
    Expression<String>? facilityId,
    Expression<String>? assigneeId,
    Expression<String>? patientId,
    Expression<String>? title,
    Expression<String>? taskType,
    Expression<String>? status,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (facilityId != null) 'facility_id': facilityId,
      if (assigneeId != null) 'assignee_id': assigneeId,
      if (patientId != null) 'patient_id': patientId,
      if (title != null) 'title': title,
      if (taskType != null) 'task_type': taskType,
      if (status != null) 'status': status,
      if (dueAt != null) 'due_at': dueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClinicalTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? facilityId,
    Value<String?>? assigneeId,
    Value<String?>? patientId,
    Value<String>? title,
    Value<String>? taskType,
    Value<String>? status,
    Value<DateTime?>? dueAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ClinicalTasksCompanion(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      assigneeId: assigneeId ?? this.assigneeId,
      patientId: patientId ?? this.patientId,
      title: title ?? this.title,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (assigneeId.present) {
      map['assignee_id'] = Variable<String>(assigneeId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<String>(taskType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalTasksCompanion(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('assigneeId: $assigneeId, ')
          ..write('patientId: $patientId, ')
          ..write('title: $title, ')
          ..write('taskType: $taskType, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InternalMessagesTable extends InternalMessages
    with TableInfo<$InternalMessagesTable, InternalMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InternalMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facilities (id)',
    ),
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipientIdMeta = const VerificationMeta(
    'recipientId',
  );
  @override
  late final GeneratedColumn<String> recipientId = GeneratedColumn<String>(
    'recipient_id',
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
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    facilityId,
    senderId,
    recipientId,
    body,
    sentAt,
    read,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'internal_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<InternalMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('recipient_id')) {
      context.handle(
        _recipientIdMeta,
        recipientId.isAcceptableOrUnknown(
          data['recipient_id']!,
          _recipientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recipientIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    if (data.containsKey('read')) {
      context.handle(
        _readMeta,
        read.isAcceptableOrUnknown(data['read']!, _readMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InternalMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InternalMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      recipientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      )!,
      read: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read'],
      )!,
    );
  }

  @override
  $InternalMessagesTable createAlias(String alias) {
    return $InternalMessagesTable(attachedDatabase, alias);
  }
}

class InternalMessage extends DataClass implements Insertable<InternalMessage> {
  final String id;
  final String facilityId;
  final String senderId;
  final String recipientId;
  final String body;
  final DateTime sentAt;
  final bool read;
  const InternalMessage({
    required this.id,
    required this.facilityId,
    required this.senderId,
    required this.recipientId,
    required this.body,
    required this.sentAt,
    required this.read,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['facility_id'] = Variable<String>(facilityId);
    map['sender_id'] = Variable<String>(senderId);
    map['recipient_id'] = Variable<String>(recipientId);
    map['body'] = Variable<String>(body);
    map['sent_at'] = Variable<DateTime>(sentAt);
    map['read'] = Variable<bool>(read);
    return map;
  }

  InternalMessagesCompanion toCompanion(bool nullToAbsent) {
    return InternalMessagesCompanion(
      id: Value(id),
      facilityId: Value(facilityId),
      senderId: Value(senderId),
      recipientId: Value(recipientId),
      body: Value(body),
      sentAt: Value(sentAt),
      read: Value(read),
    );
  }

  factory InternalMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InternalMessage(
      id: serializer.fromJson<String>(json['id']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      recipientId: serializer.fromJson<String>(json['recipientId']),
      body: serializer.fromJson<String>(json['body']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
      read: serializer.fromJson<bool>(json['read']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'facilityId': serializer.toJson<String>(facilityId),
      'senderId': serializer.toJson<String>(senderId),
      'recipientId': serializer.toJson<String>(recipientId),
      'body': serializer.toJson<String>(body),
      'sentAt': serializer.toJson<DateTime>(sentAt),
      'read': serializer.toJson<bool>(read),
    };
  }

  InternalMessage copyWith({
    String? id,
    String? facilityId,
    String? senderId,
    String? recipientId,
    String? body,
    DateTime? sentAt,
    bool? read,
  }) => InternalMessage(
    id: id ?? this.id,
    facilityId: facilityId ?? this.facilityId,
    senderId: senderId ?? this.senderId,
    recipientId: recipientId ?? this.recipientId,
    body: body ?? this.body,
    sentAt: sentAt ?? this.sentAt,
    read: read ?? this.read,
  );
  InternalMessage copyWithCompanion(InternalMessagesCompanion data) {
    return InternalMessage(
      id: data.id.present ? data.id.value : this.id,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      recipientId: data.recipientId.present
          ? data.recipientId.value
          : this.recipientId,
      body: data.body.present ? data.body.value : this.body,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      read: data.read.present ? data.read.value : this.read,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InternalMessage(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('senderId: $senderId, ')
          ..write('recipientId: $recipientId, ')
          ..write('body: $body, ')
          ..write('sentAt: $sentAt, ')
          ..write('read: $read')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, facilityId, senderId, recipientId, body, sentAt, read);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InternalMessage &&
          other.id == this.id &&
          other.facilityId == this.facilityId &&
          other.senderId == this.senderId &&
          other.recipientId == this.recipientId &&
          other.body == this.body &&
          other.sentAt == this.sentAt &&
          other.read == this.read);
}

class InternalMessagesCompanion extends UpdateCompanion<InternalMessage> {
  final Value<String> id;
  final Value<String> facilityId;
  final Value<String> senderId;
  final Value<String> recipientId;
  final Value<String> body;
  final Value<DateTime> sentAt;
  final Value<bool> read;
  final Value<int> rowid;
  const InternalMessagesCompanion({
    this.id = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.recipientId = const Value.absent(),
    this.body = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.read = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InternalMessagesCompanion.insert({
    required String id,
    required String facilityId,
    required String senderId,
    required String recipientId,
    required String body,
    required DateTime sentAt,
    this.read = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityId = Value(facilityId),
       senderId = Value(senderId),
       recipientId = Value(recipientId),
       body = Value(body),
       sentAt = Value(sentAt);
  static Insertable<InternalMessage> custom({
    Expression<String>? id,
    Expression<String>? facilityId,
    Expression<String>? senderId,
    Expression<String>? recipientId,
    Expression<String>? body,
    Expression<DateTime>? sentAt,
    Expression<bool>? read,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (facilityId != null) 'facility_id': facilityId,
      if (senderId != null) 'sender_id': senderId,
      if (recipientId != null) 'recipient_id': recipientId,
      if (body != null) 'body': body,
      if (sentAt != null) 'sent_at': sentAt,
      if (read != null) 'read': read,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InternalMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? facilityId,
    Value<String>? senderId,
    Value<String>? recipientId,
    Value<String>? body,
    Value<DateTime>? sentAt,
    Value<bool>? read,
    Value<int>? rowid,
  }) {
    return InternalMessagesCompanion(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      read: read ?? this.read,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (recipientId.present) {
      map['recipient_id'] = Variable<String>(recipientId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InternalMessagesCompanion(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('senderId: $senderId, ')
          ..write('recipientId: $recipientId, ')
          ..write('body: $body, ')
          ..write('sentAt: $sentAt, ')
          ..write('read: $read, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PractitionerCredentialsTable extends PractitionerCredentials
    with TableInfo<$PractitionerCredentialsTable, PractitionerCredential> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PractitionerCredentialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _credentialTypeMeta = const VerificationMeta(
    'credentialType',
  );
  @override
  late final GeneratedColumn<String> credentialType = GeneratedColumn<String>(
    'credential_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
    'issued_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    credentialType,
    title,
    issuedAt,
    expiresAt,
    storagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practitioner_credentials';
  @override
  VerificationContext validateIntegrity(
    Insertable<PractitionerCredential> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('credential_type')) {
      context.handle(
        _credentialTypeMeta,
        credentialType.isAcceptableOrUnknown(
          data['credential_type']!,
          _credentialTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_credentialTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PractitionerCredential map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PractitionerCredential(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      credentialType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credential_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issued_at'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      ),
    );
  }

  @override
  $PractitionerCredentialsTable createAlias(String alias) {
    return $PractitionerCredentialsTable(attachedDatabase, alias);
  }
}

class PractitionerCredential extends DataClass
    implements Insertable<PractitionerCredential> {
  final String id;
  final String providerId;
  final String credentialType;
  final String title;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final String? storagePath;
  const PractitionerCredential({
    required this.id,
    required this.providerId,
    required this.credentialType,
    required this.title,
    this.issuedAt,
    this.expiresAt,
    this.storagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['credential_type'] = Variable<String>(credentialType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || issuedAt != null) {
      map['issued_at'] = Variable<DateTime>(issuedAt);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    if (!nullToAbsent || storagePath != null) {
      map['storage_path'] = Variable<String>(storagePath);
    }
    return map;
  }

  PractitionerCredentialsCompanion toCompanion(bool nullToAbsent) {
    return PractitionerCredentialsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      credentialType: Value(credentialType),
      title: Value(title),
      issuedAt: issuedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(issuedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      storagePath: storagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(storagePath),
    );
  }

  factory PractitionerCredential.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PractitionerCredential(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      credentialType: serializer.fromJson<String>(json['credentialType']),
      title: serializer.fromJson<String>(json['title']),
      issuedAt: serializer.fromJson<DateTime?>(json['issuedAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      storagePath: serializer.fromJson<String?>(json['storagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'credentialType': serializer.toJson<String>(credentialType),
      'title': serializer.toJson<String>(title),
      'issuedAt': serializer.toJson<DateTime?>(issuedAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'storagePath': serializer.toJson<String?>(storagePath),
    };
  }

  PractitionerCredential copyWith({
    String? id,
    String? providerId,
    String? credentialType,
    String? title,
    Value<DateTime?> issuedAt = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
    Value<String?> storagePath = const Value.absent(),
  }) => PractitionerCredential(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    credentialType: credentialType ?? this.credentialType,
    title: title ?? this.title,
    issuedAt: issuedAt.present ? issuedAt.value : this.issuedAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    storagePath: storagePath.present ? storagePath.value : this.storagePath,
  );
  PractitionerCredential copyWithCompanion(
    PractitionerCredentialsCompanion data,
  ) {
    return PractitionerCredential(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      credentialType: data.credentialType.present
          ? data.credentialType.value
          : this.credentialType,
      title: data.title.present ? data.title.value : this.title,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PractitionerCredential(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('credentialType: $credentialType, ')
          ..write('title: $title, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('storagePath: $storagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    credentialType,
    title,
    issuedAt,
    expiresAt,
    storagePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PractitionerCredential &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.credentialType == this.credentialType &&
          other.title == this.title &&
          other.issuedAt == this.issuedAt &&
          other.expiresAt == this.expiresAt &&
          other.storagePath == this.storagePath);
}

class PractitionerCredentialsCompanion
    extends UpdateCompanion<PractitionerCredential> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> credentialType;
  final Value<String> title;
  final Value<DateTime?> issuedAt;
  final Value<DateTime?> expiresAt;
  final Value<String?> storagePath;
  final Value<int> rowid;
  const PractitionerCredentialsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.credentialType = const Value.absent(),
    this.title = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PractitionerCredentialsCompanion.insert({
    required String id,
    required String providerId,
    required String credentialType,
    required String title,
    this.issuedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       credentialType = Value(credentialType),
       title = Value(title);
  static Insertable<PractitionerCredential> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? credentialType,
    Expression<String>? title,
    Expression<DateTime>? issuedAt,
    Expression<DateTime>? expiresAt,
    Expression<String>? storagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (credentialType != null) 'credential_type': credentialType,
      if (title != null) 'title': title,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (storagePath != null) 'storage_path': storagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PractitionerCredentialsCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? credentialType,
    Value<String>? title,
    Value<DateTime?>? issuedAt,
    Value<DateTime?>? expiresAt,
    Value<String?>? storagePath,
    Value<int>? rowid,
  }) {
    return PractitionerCredentialsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      credentialType: credentialType ?? this.credentialType,
      title: title ?? this.title,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      storagePath: storagePath ?? this.storagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (credentialType.present) {
      map['credential_type'] = Variable<String>(credentialType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PractitionerCredentialsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('credentialType: $credentialType, ')
          ..write('title: $title, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('storagePath: $storagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancialSummariesTable extends FinancialSummaries
    with TableInfo<$FinancialSummariesTable, FinancialSummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facilities (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revenueMeta = const VerificationMeta(
    'revenue',
  );
  @override
  late final GeneratedColumn<double> revenue = GeneratedColumn<double>(
    'revenue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expensesMeta = const VerificationMeta(
    'expenses',
  );
  @override
  late final GeneratedColumn<double> expenses = GeneratedColumn<double>(
    'expenses',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outstandingMeta = const VerificationMeta(
    'outstanding',
  );
  @override
  late final GeneratedColumn<double> outstanding = GeneratedColumn<double>(
    'outstanding',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    facilityId,
    providerId,
    period,
    revenue,
    expenses,
    outstanding,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinancialSummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('revenue')) {
      context.handle(
        _revenueMeta,
        revenue.isAcceptableOrUnknown(data['revenue']!, _revenueMeta),
      );
    }
    if (data.containsKey('expenses')) {
      context.handle(
        _expensesMeta,
        expenses.isAcceptableOrUnknown(data['expenses']!, _expensesMeta),
      );
    }
    if (data.containsKey('outstanding')) {
      context.handle(
        _outstandingMeta,
        outstanding.isAcceptableOrUnknown(
          data['outstanding']!,
          _outstandingMeta,
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
  FinancialSummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialSummary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      revenue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}revenue'],
      )!,
      expenses: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expenses'],
      )!,
      outstanding: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}outstanding'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FinancialSummariesTable createAlias(String alias) {
    return $FinancialSummariesTable(attachedDatabase, alias);
  }
}

class FinancialSummary extends DataClass
    implements Insertable<FinancialSummary> {
  final String id;
  final String facilityId;
  final String? providerId;
  final String period;
  final double revenue;
  final double expenses;
  final double outstanding;
  final DateTime updatedAt;
  const FinancialSummary({
    required this.id,
    required this.facilityId,
    this.providerId,
    required this.period,
    required this.revenue,
    required this.expenses,
    required this.outstanding,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['facility_id'] = Variable<String>(facilityId);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    map['period'] = Variable<String>(period);
    map['revenue'] = Variable<double>(revenue);
    map['expenses'] = Variable<double>(expenses);
    map['outstanding'] = Variable<double>(outstanding);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FinancialSummariesCompanion toCompanion(bool nullToAbsent) {
    return FinancialSummariesCompanion(
      id: Value(id),
      facilityId: Value(facilityId),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      period: Value(period),
      revenue: Value(revenue),
      expenses: Value(expenses),
      outstanding: Value(outstanding),
      updatedAt: Value(updatedAt),
    );
  }

  factory FinancialSummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialSummary(
      id: serializer.fromJson<String>(json['id']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      period: serializer.fromJson<String>(json['period']),
      revenue: serializer.fromJson<double>(json['revenue']),
      expenses: serializer.fromJson<double>(json['expenses']),
      outstanding: serializer.fromJson<double>(json['outstanding']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'facilityId': serializer.toJson<String>(facilityId),
      'providerId': serializer.toJson<String?>(providerId),
      'period': serializer.toJson<String>(period),
      'revenue': serializer.toJson<double>(revenue),
      'expenses': serializer.toJson<double>(expenses),
      'outstanding': serializer.toJson<double>(outstanding),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FinancialSummary copyWith({
    String? id,
    String? facilityId,
    Value<String?> providerId = const Value.absent(),
    String? period,
    double? revenue,
    double? expenses,
    double? outstanding,
    DateTime? updatedAt,
  }) => FinancialSummary(
    id: id ?? this.id,
    facilityId: facilityId ?? this.facilityId,
    providerId: providerId.present ? providerId.value : this.providerId,
    period: period ?? this.period,
    revenue: revenue ?? this.revenue,
    expenses: expenses ?? this.expenses,
    outstanding: outstanding ?? this.outstanding,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FinancialSummary copyWithCompanion(FinancialSummariesCompanion data) {
    return FinancialSummary(
      id: data.id.present ? data.id.value : this.id,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      period: data.period.present ? data.period.value : this.period,
      revenue: data.revenue.present ? data.revenue.value : this.revenue,
      expenses: data.expenses.present ? data.expenses.value : this.expenses,
      outstanding: data.outstanding.present
          ? data.outstanding.value
          : this.outstanding,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialSummary(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('providerId: $providerId, ')
          ..write('period: $period, ')
          ..write('revenue: $revenue, ')
          ..write('expenses: $expenses, ')
          ..write('outstanding: $outstanding, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    facilityId,
    providerId,
    period,
    revenue,
    expenses,
    outstanding,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialSummary &&
          other.id == this.id &&
          other.facilityId == this.facilityId &&
          other.providerId == this.providerId &&
          other.period == this.period &&
          other.revenue == this.revenue &&
          other.expenses == this.expenses &&
          other.outstanding == this.outstanding &&
          other.updatedAt == this.updatedAt);
}

class FinancialSummariesCompanion extends UpdateCompanion<FinancialSummary> {
  final Value<String> id;
  final Value<String> facilityId;
  final Value<String?> providerId;
  final Value<String> period;
  final Value<double> revenue;
  final Value<double> expenses;
  final Value<double> outstanding;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FinancialSummariesCompanion({
    this.id = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.period = const Value.absent(),
    this.revenue = const Value.absent(),
    this.expenses = const Value.absent(),
    this.outstanding = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialSummariesCompanion.insert({
    required String id,
    required String facilityId,
    this.providerId = const Value.absent(),
    required String period,
    this.revenue = const Value.absent(),
    this.expenses = const Value.absent(),
    this.outstanding = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityId = Value(facilityId),
       period = Value(period),
       updatedAt = Value(updatedAt);
  static Insertable<FinancialSummary> custom({
    Expression<String>? id,
    Expression<String>? facilityId,
    Expression<String>? providerId,
    Expression<String>? period,
    Expression<double>? revenue,
    Expression<double>? expenses,
    Expression<double>? outstanding,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (facilityId != null) 'facility_id': facilityId,
      if (providerId != null) 'provider_id': providerId,
      if (period != null) 'period': period,
      if (revenue != null) 'revenue': revenue,
      if (expenses != null) 'expenses': expenses,
      if (outstanding != null) 'outstanding': outstanding,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialSummariesCompanion copyWith({
    Value<String>? id,
    Value<String>? facilityId,
    Value<String?>? providerId,
    Value<String>? period,
    Value<double>? revenue,
    Value<double>? expenses,
    Value<double>? outstanding,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FinancialSummariesCompanion(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      providerId: providerId ?? this.providerId,
      period: period ?? this.period,
      revenue: revenue ?? this.revenue,
      expenses: expenses ?? this.expenses,
      outstanding: outstanding ?? this.outstanding,
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
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (revenue.present) {
      map['revenue'] = Variable<double>(revenue.value);
    }
    if (expenses.present) {
      map['expenses'] = Variable<double>(expenses.value);
    }
    if (outstanding.present) {
      map['outstanding'] = Variable<double>(outstanding.value);
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
    return (StringBuffer('FinancialSummariesCompanion(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('providerId: $providerId, ')
          ..write('period: $period, ')
          ..write('revenue: $revenue, ')
          ..write('expenses: $expenses, ')
          ..write('outstanding: $outstanding, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FacilitiesTable facilities = $FacilitiesTable(this);
  late final $FacilityMembershipsTable facilityMemberships =
      $FacilityMembershipsTable(this);
  late final $PractitionersTable practitioners = $PractitionersTable(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $PatientAllergiesTable patientAllergies = $PatientAllergiesTable(
    this,
  );
  late final $PatientConditionsTable patientConditions =
      $PatientConditionsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $QueueEntriesTable queueEntries = $QueueEntriesTable(this);
  late final $ConsultationsTable consultations = $ConsultationsTable(this);
  late final $DiagnosesTable diagnoses = $DiagnosesTable(this);
  late final $VitalsTable vitals = $VitalsTable(this);
  late final $PrescriptionsTable prescriptions = $PrescriptionsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $FeatureFlagsTable featureFlags = $FeatureFlagsTable(this);
  late final $Icd11CodesTable icd11Codes = $Icd11CodesTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $EdlizRecommendationsTable edlizRecommendations =
      $EdlizRecommendationsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $InsuranceClaimsTable insuranceClaims = $InsuranceClaimsTable(
    this,
  );
  late final $ClinicalTasksTable clinicalTasks = $ClinicalTasksTable(this);
  late final $InternalMessagesTable internalMessages = $InternalMessagesTable(
    this,
  );
  late final $PractitionerCredentialsTable practitionerCredentials =
      $PractitionerCredentialsTable(this);
  late final $FinancialSummariesTable financialSummaries =
      $FinancialSummariesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    facilities,
    facilityMemberships,
    practitioners,
    patients,
    patientAllergies,
    patientConditions,
    appointments,
    queueEntries,
    consultations,
    diagnoses,
    vitals,
    prescriptions,
    syncQueue,
    syncCursors,
    featureFlags,
    icd11Codes,
    medications,
    edlizRecommendations,
    auditLogs,
    insuranceClaims,
    clinicalTasks,
    internalMessages,
    practitionerCredentials,
    financialSummaries,
  ];
}

typedef $$FacilitiesTableCreateCompanionBuilder =
    FacilitiesCompanion Function({
      required String id,
      Value<String?> serverId,
      required String name,
      Value<String?> city,
      Value<String?> address,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> logoUrl,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$FacilitiesTableUpdateCompanionBuilder =
    FacilitiesCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> name,
      Value<String?> city,
      Value<String?> address,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> logoUrl,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$FacilitiesTableReferences
    extends BaseReferences<_$AppDatabase, $FacilitiesTable, Facility> {
  $$FacilitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $FacilityMembershipsTable,
    List<FacilityMembership>
  >
  _facilityMembershipsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.facilityMemberships,
        aliasName: 'facilities__id__facility_memberships__facility_id',
      );

  $$FacilityMembershipsTableProcessedTableManager get facilityMembershipsRefs {
    final manager = $$FacilityMembershipsTableTableManager(
      $_db,
      $_db.facilityMemberships,
    ).filter((f) => f.facilityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _facilityMembershipsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PractitionersTable, List<Practitioner>>
  _practitionersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.practitioners,
    aliasName: 'facilities__id__practitioners__facility_id',
  );

  $$PractitionersTableProcessedTableManager get practitionersRefs {
    final manager = $$PractitionersTableTableManager(
      $_db,
      $_db.practitioners,
    ).filter((f) => f.facilityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_practitionersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AppointmentsTable, List<Appointment>>
  _appointmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.appointments,
    aliasName: 'facilities__id__appointments__facility_id',
  );

  $$AppointmentsTableProcessedTableManager get appointmentsRefs {
    final manager = $$AppointmentsTableTableManager(
      $_db,
      $_db.appointments,
    ).filter((f) => f.facilityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_appointmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QueueEntriesTable, List<QueueEntry>>
  _queueEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queueEntries,
    aliasName: 'facilities__id__queue_entries__facility_id',
  );

  $$QueueEntriesTableProcessedTableManager get queueEntriesRefs {
    final manager = $$QueueEntriesTableTableManager(
      $_db,
      $_db.queueEntries,
    ).filter((f) => f.facilityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConsultationsTable, List<Consultation>>
  _consultationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.consultations,
    aliasName: 'facilities__id__consultations__facility_id',
  );

  $$ConsultationsTableProcessedTableManager get consultationsRefs {
    final manager = $$ConsultationsTableTableManager(
      $_db,
      $_db.consultations,
    ).filter((f) => f.facilityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_consultationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InsuranceClaimsTable, List<InsuranceClaim>>
  _insuranceClaimsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.insuranceClaims,
    aliasName: 'facilities__id__insurance_claims__facility_id',
  );

  $$InsuranceClaimsTableProcessedTableManager get insuranceClaimsRefs {
    final manager = $$InsuranceClaimsTableTableManager(
      $_db,
      $_db.insuranceClaims,
    ).filter((f) => f.facilityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _insuranceClaimsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ClinicalTasksTable, List<ClinicalTask>>
  _clinicalTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clinicalTasks,
    aliasName: 'facilities__id__clinical_tasks__facility_id',
  );

  $$ClinicalTasksTableProcessedTableManager get clinicalTasksRefs {
    final manager = $$ClinicalTasksTableTableManager(
      $_db,
      $_db.clinicalTasks,
    ).filter((f) => f.facilityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_clinicalTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InternalMessagesTable, List<InternalMessage>>
  _internalMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.internalMessages,
    aliasName: 'facilities__id__internal_messages__facility_id',
  );

  $$InternalMessagesTableProcessedTableManager get internalMessagesRefs {
    final manager = $$InternalMessagesTableTableManager(
      $_db,
      $_db.internalMessages,
    ).filter((f) => f.facilityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _internalMessagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FinancialSummariesTable, List<FinancialSummary>>
  _financialSummariesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.financialSummaries,
        aliasName: 'facilities__id__financial_summaries__facility_id',
      );

  $$FinancialSummariesTableProcessedTableManager get financialSummariesRefs {
    final manager = $$FinancialSummariesTableTableManager(
      $_db,
      $_db.financialSummaries,
    ).filter((f) => f.facilityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _financialSummariesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FacilitiesTableFilterComposer
    extends Composer<_$AppDatabase, $FacilitiesTable> {
  $$FacilitiesTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> facilityMembershipsRefs(
    Expression<bool> Function($$FacilityMembershipsTableFilterComposer f) f,
  ) {
    final $$FacilityMembershipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facilityMemberships,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilityMembershipsTableFilterComposer(
            $db: $db,
            $table: $db.facilityMemberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> practitionersRefs(
    Expression<bool> Function($$PractitionersTableFilterComposer f) f,
  ) {
    final $$PractitionersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practitioners,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PractitionersTableFilterComposer(
            $db: $db,
            $table: $db.practitioners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> appointmentsRefs(
    Expression<bool> Function($$AppointmentsTableFilterComposer f) f,
  ) {
    final $$AppointmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appointments,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppointmentsTableFilterComposer(
            $db: $db,
            $table: $db.appointments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> queueEntriesRefs(
    Expression<bool> Function($$QueueEntriesTableFilterComposer f) f,
  ) {
    final $$QueueEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueEntries,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueEntriesTableFilterComposer(
            $db: $db,
            $table: $db.queueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> consultationsRefs(
    Expression<bool> Function($$ConsultationsTableFilterComposer f) f,
  ) {
    final $$ConsultationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableFilterComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> insuranceClaimsRefs(
    Expression<bool> Function($$InsuranceClaimsTableFilterComposer f) f,
  ) {
    final $$InsuranceClaimsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.insuranceClaims,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsuranceClaimsTableFilterComposer(
            $db: $db,
            $table: $db.insuranceClaims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> clinicalTasksRefs(
    Expression<bool> Function($$ClinicalTasksTableFilterComposer f) f,
  ) {
    final $$ClinicalTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalTasks,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalTasksTableFilterComposer(
            $db: $db,
            $table: $db.clinicalTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> internalMessagesRefs(
    Expression<bool> Function($$InternalMessagesTableFilterComposer f) f,
  ) {
    final $$InternalMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.internalMessages,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InternalMessagesTableFilterComposer(
            $db: $db,
            $table: $db.internalMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> financialSummariesRefs(
    Expression<bool> Function($$FinancialSummariesTableFilterComposer f) f,
  ) {
    final $$FinancialSummariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.financialSummaries,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FinancialSummariesTableFilterComposer(
            $db: $db,
            $table: $db.financialSummaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FacilitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $FacilitiesTable> {
  $$FacilitiesTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FacilitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FacilitiesTable> {
  $$FacilitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> facilityMembershipsRefs<T extends Object>(
    Expression<T> Function($$FacilityMembershipsTableAnnotationComposer a) f,
  ) {
    final $$FacilityMembershipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.facilityMemberships,
          getReferencedColumn: (t) => t.facilityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FacilityMembershipsTableAnnotationComposer(
                $db: $db,
                $table: $db.facilityMemberships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> practitionersRefs<T extends Object>(
    Expression<T> Function($$PractitionersTableAnnotationComposer a) f,
  ) {
    final $$PractitionersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practitioners,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PractitionersTableAnnotationComposer(
            $db: $db,
            $table: $db.practitioners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> appointmentsRefs<T extends Object>(
    Expression<T> Function($$AppointmentsTableAnnotationComposer a) f,
  ) {
    final $$AppointmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appointments,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppointmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.appointments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> queueEntriesRefs<T extends Object>(
    Expression<T> Function($$QueueEntriesTableAnnotationComposer a) f,
  ) {
    final $$QueueEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueEntries,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.queueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> consultationsRefs<T extends Object>(
    Expression<T> Function($$ConsultationsTableAnnotationComposer a) f,
  ) {
    final $$ConsultationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableAnnotationComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> insuranceClaimsRefs<T extends Object>(
    Expression<T> Function($$InsuranceClaimsTableAnnotationComposer a) f,
  ) {
    final $$InsuranceClaimsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.insuranceClaims,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsuranceClaimsTableAnnotationComposer(
            $db: $db,
            $table: $db.insuranceClaims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> clinicalTasksRefs<T extends Object>(
    Expression<T> Function($$ClinicalTasksTableAnnotationComposer a) f,
  ) {
    final $$ClinicalTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalTasks,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.clinicalTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> internalMessagesRefs<T extends Object>(
    Expression<T> Function($$InternalMessagesTableAnnotationComposer a) f,
  ) {
    final $$InternalMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.internalMessages,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InternalMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.internalMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> financialSummariesRefs<T extends Object>(
    Expression<T> Function($$FinancialSummariesTableAnnotationComposer a) f,
  ) {
    final $$FinancialSummariesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.financialSummaries,
          getReferencedColumn: (t) => t.facilityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FinancialSummariesTableAnnotationComposer(
                $db: $db,
                $table: $db.financialSummaries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FacilitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FacilitiesTable,
          Facility,
          $$FacilitiesTableFilterComposer,
          $$FacilitiesTableOrderingComposer,
          $$FacilitiesTableAnnotationComposer,
          $$FacilitiesTableCreateCompanionBuilder,
          $$FacilitiesTableUpdateCompanionBuilder,
          (Facility, $$FacilitiesTableReferences),
          Facility,
          PrefetchHooks Function({
            bool facilityMembershipsRefs,
            bool practitionersRefs,
            bool appointmentsRefs,
            bool queueEntriesRefs,
            bool consultationsRefs,
            bool insuranceClaimsRefs,
            bool clinicalTasksRefs,
            bool internalMessagesRefs,
            bool financialSummariesRefs,
          })
        > {
  $$FacilitiesTableTableManager(_$AppDatabase db, $FacilitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FacilitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FacilitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FacilitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FacilitiesCompanion(
                id: id,
                serverId: serverId,
                name: name,
                city: city,
                address: address,
                latitude: latitude,
                longitude: longitude,
                logoUrl: logoUrl,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String name,
                Value<String?> city = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FacilitiesCompanion.insert(
                id: id,
                serverId: serverId,
                name: name,
                city: city,
                address: address,
                latitude: latitude,
                longitude: longitude,
                logoUrl: logoUrl,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FacilitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                facilityMembershipsRefs = false,
                practitionersRefs = false,
                appointmentsRefs = false,
                queueEntriesRefs = false,
                consultationsRefs = false,
                insuranceClaimsRefs = false,
                clinicalTasksRefs = false,
                internalMessagesRefs = false,
                financialSummariesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (facilityMembershipsRefs) db.facilityMemberships,
                    if (practitionersRefs) db.practitioners,
                    if (appointmentsRefs) db.appointments,
                    if (queueEntriesRefs) db.queueEntries,
                    if (consultationsRefs) db.consultations,
                    if (insuranceClaimsRefs) db.insuranceClaims,
                    if (clinicalTasksRefs) db.clinicalTasks,
                    if (internalMessagesRefs) db.internalMessages,
                    if (financialSummariesRefs) db.financialSummaries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (facilityMembershipsRefs)
                        await $_getPrefetchedData<
                          Facility,
                          $FacilitiesTable,
                          FacilityMembership
                        >(
                          currentTable: table,
                          referencedTable: $$FacilitiesTableReferences
                              ._facilityMembershipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FacilitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).facilityMembershipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.facilityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (practitionersRefs)
                        await $_getPrefetchedData<
                          Facility,
                          $FacilitiesTable,
                          Practitioner
                        >(
                          currentTable: table,
                          referencedTable: $$FacilitiesTableReferences
                              ._practitionersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FacilitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).practitionersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.facilityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (appointmentsRefs)
                        await $_getPrefetchedData<
                          Facility,
                          $FacilitiesTable,
                          Appointment
                        >(
                          currentTable: table,
                          referencedTable: $$FacilitiesTableReferences
                              ._appointmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FacilitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).appointmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.facilityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (queueEntriesRefs)
                        await $_getPrefetchedData<
                          Facility,
                          $FacilitiesTable,
                          QueueEntry
                        >(
                          currentTable: table,
                          referencedTable: $$FacilitiesTableReferences
                              ._queueEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FacilitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).queueEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.facilityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (consultationsRefs)
                        await $_getPrefetchedData<
                          Facility,
                          $FacilitiesTable,
                          Consultation
                        >(
                          currentTable: table,
                          referencedTable: $$FacilitiesTableReferences
                              ._consultationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FacilitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).consultationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.facilityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (insuranceClaimsRefs)
                        await $_getPrefetchedData<
                          Facility,
                          $FacilitiesTable,
                          InsuranceClaim
                        >(
                          currentTable: table,
                          referencedTable: $$FacilitiesTableReferences
                              ._insuranceClaimsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FacilitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).insuranceClaimsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.facilityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (clinicalTasksRefs)
                        await $_getPrefetchedData<
                          Facility,
                          $FacilitiesTable,
                          ClinicalTask
                        >(
                          currentTable: table,
                          referencedTable: $$FacilitiesTableReferences
                              ._clinicalTasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FacilitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).clinicalTasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.facilityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (internalMessagesRefs)
                        await $_getPrefetchedData<
                          Facility,
                          $FacilitiesTable,
                          InternalMessage
                        >(
                          currentTable: table,
                          referencedTable: $$FacilitiesTableReferences
                              ._internalMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FacilitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).internalMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.facilityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (financialSummariesRefs)
                        await $_getPrefetchedData<
                          Facility,
                          $FacilitiesTable,
                          FinancialSummary
                        >(
                          currentTable: table,
                          referencedTable: $$FacilitiesTableReferences
                              ._financialSummariesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FacilitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).financialSummariesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.facilityId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FacilitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FacilitiesTable,
      Facility,
      $$FacilitiesTableFilterComposer,
      $$FacilitiesTableOrderingComposer,
      $$FacilitiesTableAnnotationComposer,
      $$FacilitiesTableCreateCompanionBuilder,
      $$FacilitiesTableUpdateCompanionBuilder,
      (Facility, $$FacilitiesTableReferences),
      Facility,
      PrefetchHooks Function({
        bool facilityMembershipsRefs,
        bool practitionersRefs,
        bool appointmentsRefs,
        bool queueEntriesRefs,
        bool consultationsRefs,
        bool insuranceClaimsRefs,
        bool clinicalTasksRefs,
        bool internalMessagesRefs,
        bool financialSummariesRefs,
      })
    >;
typedef $$FacilityMembershipsTableCreateCompanionBuilder =
    FacilityMembershipsCompanion Function({
      required String id,
      required String facilityId,
      required String userId,
      required String role,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FacilityMembershipsTableUpdateCompanionBuilder =
    FacilityMembershipsCompanion Function({
      Value<String> id,
      Value<String> facilityId,
      Value<String> userId,
      Value<String> role,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$FacilityMembershipsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FacilityMembershipsTable,
          FacilityMembership
        > {
  $$FacilityMembershipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FacilitiesTable _facilityIdTable(_$AppDatabase db) => db.facilities
      .createAlias('facility_memberships__facility_id__facilities__id');

  $$FacilitiesTableProcessedTableManager get facilityId {
    final $_column = $_itemColumn<String>('facility_id')!;

    final manager = $$FacilitiesTableTableManager(
      $_db,
      $_db.facilities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FacilityMembershipsTableFilterComposer
    extends Composer<_$AppDatabase, $FacilityMembershipsTable> {
  $$FacilityMembershipsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FacilitiesTableFilterComposer get facilityId {
    final $$FacilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableFilterComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FacilityMembershipsTableOrderingComposer
    extends Composer<_$AppDatabase, $FacilityMembershipsTable> {
  $$FacilityMembershipsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacilitiesTableOrderingComposer get facilityId {
    final $$FacilitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableOrderingComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FacilityMembershipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FacilityMembershipsTable> {
  $$FacilityMembershipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FacilitiesTableAnnotationComposer get facilityId {
    final $$FacilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FacilityMembershipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FacilityMembershipsTable,
          FacilityMembership,
          $$FacilityMembershipsTableFilterComposer,
          $$FacilityMembershipsTableOrderingComposer,
          $$FacilityMembershipsTableAnnotationComposer,
          $$FacilityMembershipsTableCreateCompanionBuilder,
          $$FacilityMembershipsTableUpdateCompanionBuilder,
          (FacilityMembership, $$FacilityMembershipsTableReferences),
          FacilityMembership,
          PrefetchHooks Function({bool facilityId})
        > {
  $$FacilityMembershipsTableTableManager(
    _$AppDatabase db,
    $FacilityMembershipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FacilityMembershipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FacilityMembershipsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FacilityMembershipsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FacilityMembershipsCompanion(
                id: id,
                facilityId: facilityId,
                userId: userId,
                role: role,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String facilityId,
                required String userId,
                required String role,
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FacilityMembershipsCompanion.insert(
                id: id,
                facilityId: facilityId,
                userId: userId,
                role: role,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FacilityMembershipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({facilityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (facilityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.facilityId,
                                referencedTable:
                                    $$FacilityMembershipsTableReferences
                                        ._facilityIdTable(db),
                                referencedColumn:
                                    $$FacilityMembershipsTableReferences
                                        ._facilityIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FacilityMembershipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FacilityMembershipsTable,
      FacilityMembership,
      $$FacilityMembershipsTableFilterComposer,
      $$FacilityMembershipsTableOrderingComposer,
      $$FacilityMembershipsTableAnnotationComposer,
      $$FacilityMembershipsTableCreateCompanionBuilder,
      $$FacilityMembershipsTableUpdateCompanionBuilder,
      (FacilityMembership, $$FacilityMembershipsTableReferences),
      FacilityMembership,
      PrefetchHooks Function({bool facilityId})
    >;
typedef $$PractitionersTableCreateCompanionBuilder =
    PractitionersCompanion Function({
      required String id,
      Value<String?> serverId,
      required String facilityId,
      required String name,
      Value<String?> specialty,
      Value<String?> registrationNumber,
      Value<String?> role,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PractitionersTableUpdateCompanionBuilder =
    PractitionersCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> facilityId,
      Value<String> name,
      Value<String?> specialty,
      Value<String?> registrationNumber,
      Value<String?> role,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PractitionersTableReferences
    extends BaseReferences<_$AppDatabase, $PractitionersTable, Practitioner> {
  $$PractitionersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FacilitiesTable _facilityIdTable(_$AppDatabase db) =>
      db.facilities.createAlias('practitioners__facility_id__facilities__id');

  $$FacilitiesTableProcessedTableManager get facilityId {
    final $_column = $_itemColumn<String>('facility_id')!;

    final manager = $$FacilitiesTableTableManager(
      $_db,
      $_db.facilities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PractitionersTableFilterComposer
    extends Composer<_$AppDatabase, $PractitionersTable> {
  $$PractitionersTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FacilitiesTableFilterComposer get facilityId {
    final $$FacilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableFilterComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PractitionersTableOrderingComposer
    extends Composer<_$AppDatabase, $PractitionersTable> {
  $$PractitionersTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacilitiesTableOrderingComposer get facilityId {
    final $$FacilitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableOrderingComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PractitionersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PractitionersTable> {
  $$PractitionersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);

  GeneratedColumn<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FacilitiesTableAnnotationComposer get facilityId {
    final $$FacilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PractitionersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PractitionersTable,
          Practitioner,
          $$PractitionersTableFilterComposer,
          $$PractitionersTableOrderingComposer,
          $$PractitionersTableAnnotationComposer,
          $$PractitionersTableCreateCompanionBuilder,
          $$PractitionersTableUpdateCompanionBuilder,
          (Practitioner, $$PractitionersTableReferences),
          Practitioner,
          PrefetchHooks Function({bool facilityId})
        > {
  $$PractitionersTableTableManager(_$AppDatabase db, $PractitionersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PractitionersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PractitionersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PractitionersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> specialty = const Value.absent(),
                Value<String?> registrationNumber = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PractitionersCompanion(
                id: id,
                serverId: serverId,
                facilityId: facilityId,
                name: name,
                specialty: specialty,
                registrationNumber: registrationNumber,
                role: role,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String facilityId,
                required String name,
                Value<String?> specialty = const Value.absent(),
                Value<String?> registrationNumber = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PractitionersCompanion.insert(
                id: id,
                serverId: serverId,
                facilityId: facilityId,
                name: name,
                specialty: specialty,
                registrationNumber: registrationNumber,
                role: role,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PractitionersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({facilityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (facilityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.facilityId,
                                referencedTable: $$PractitionersTableReferences
                                    ._facilityIdTable(db),
                                referencedColumn: $$PractitionersTableReferences
                                    ._facilityIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PractitionersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PractitionersTable,
      Practitioner,
      $$PractitionersTableFilterComposer,
      $$PractitionersTableOrderingComposer,
      $$PractitionersTableAnnotationComposer,
      $$PractitionersTableCreateCompanionBuilder,
      $$PractitionersTableUpdateCompanionBuilder,
      (Practitioner, $$PractitionersTableReferences),
      Practitioner,
      PrefetchHooks Function({bool facilityId})
    >;
typedef $$PatientsTableCreateCompanionBuilder =
    PatientsCompanion Function({
      required String id,
      Value<String?> serverId,
      Value<String?> smarthealthPatientId,
      Value<String?> nationalId,
      Value<String?> passport,
      required String firstName,
      required String lastName,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> gender,
      Value<DateTime?> dateOfBirth,
      Value<String?> insuranceInfo,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PatientsTableUpdateCompanionBuilder =
    PatientsCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String?> smarthealthPatientId,
      Value<String?> nationalId,
      Value<String?> passport,
      Value<String> firstName,
      Value<String> lastName,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> gender,
      Value<DateTime?> dateOfBirth,
      Value<String?> insuranceInfo,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$PatientsTableReferences
    extends BaseReferences<_$AppDatabase, $PatientsTable, Patient> {
  $$PatientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PatientAllergiesTable, List<PatientAllergy>>
  _patientAllergiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.patientAllergies,
    aliasName: 'patients__id__patient_allergies__patient_id',
  );

  $$PatientAllergiesTableProcessedTableManager get patientAllergiesRefs {
    final manager = $$PatientAllergiesTableTableManager(
      $_db,
      $_db.patientAllergies,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _patientAllergiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PatientConditionsTable, List<PatientCondition>>
  _patientConditionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.patientConditions,
        aliasName: 'patients__id__patient_conditions__patient_id',
      );

  $$PatientConditionsTableProcessedTableManager get patientConditionsRefs {
    final manager = $$PatientConditionsTableTableManager(
      $_db,
      $_db.patientConditions,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _patientConditionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AppointmentsTable, List<Appointment>>
  _appointmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.appointments,
    aliasName: 'patients__id__appointments__patient_id',
  );

  $$AppointmentsTableProcessedTableManager get appointmentsRefs {
    final manager = $$AppointmentsTableTableManager(
      $_db,
      $_db.appointments,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_appointmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QueueEntriesTable, List<QueueEntry>>
  _queueEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queueEntries,
    aliasName: 'patients__id__queue_entries__patient_id',
  );

  $$QueueEntriesTableProcessedTableManager get queueEntriesRefs {
    final manager = $$QueueEntriesTableTableManager(
      $_db,
      $_db.queueEntries,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConsultationsTable, List<Consultation>>
  _consultationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.consultations,
    aliasName: 'patients__id__consultations__patient_id',
  );

  $$ConsultationsTableProcessedTableManager get consultationsRefs {
    final manager = $$ConsultationsTableTableManager(
      $_db,
      $_db.consultations,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_consultationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DiagnosesTable, List<Diagnose>>
  _diagnosesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diagnoses,
    aliasName: 'patients__id__diagnoses__patient_id',
  );

  $$DiagnosesTableProcessedTableManager get diagnosesRefs {
    final manager = $$DiagnosesTableTableManager(
      $_db,
      $_db.diagnoses,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_diagnosesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VitalsTable, List<Vital>> _vitalsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.vitals,
    aliasName: 'patients__id__vitals__patient_id',
  );

  $$VitalsTableProcessedTableManager get vitalsRefs {
    final manager = $$VitalsTableTableManager(
      $_db,
      $_db.vitals,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vitalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrescriptionsTable, List<Prescription>>
  _prescriptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prescriptions,
    aliasName: 'patients__id__prescriptions__patient_id',
  );

  $$PrescriptionsTableProcessedTableManager get prescriptionsRefs {
    final manager = $$PrescriptionsTableTableManager(
      $_db,
      $_db.prescriptions,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_prescriptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InsuranceClaimsTable, List<InsuranceClaim>>
  _insuranceClaimsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.insuranceClaims,
    aliasName: 'patients__id__insurance_claims__patient_id',
  );

  $$InsuranceClaimsTableProcessedTableManager get insuranceClaimsRefs {
    final manager = $$InsuranceClaimsTableTableManager(
      $_db,
      $_db.insuranceClaims,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _insuranceClaimsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smarthealthPatientId => $composableBuilder(
    column: $table.smarthealthPatientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passport => $composableBuilder(
    column: $table.passport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insuranceInfo => $composableBuilder(
    column: $table.insuranceInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> patientAllergiesRefs(
    Expression<bool> Function($$PatientAllergiesTableFilterComposer f) f,
  ) {
    final $$PatientAllergiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.patientAllergies,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientAllergiesTableFilterComposer(
            $db: $db,
            $table: $db.patientAllergies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> patientConditionsRefs(
    Expression<bool> Function($$PatientConditionsTableFilterComposer f) f,
  ) {
    final $$PatientConditionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.patientConditions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientConditionsTableFilterComposer(
            $db: $db,
            $table: $db.patientConditions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> appointmentsRefs(
    Expression<bool> Function($$AppointmentsTableFilterComposer f) f,
  ) {
    final $$AppointmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appointments,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppointmentsTableFilterComposer(
            $db: $db,
            $table: $db.appointments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> queueEntriesRefs(
    Expression<bool> Function($$QueueEntriesTableFilterComposer f) f,
  ) {
    final $$QueueEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueEntries,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueEntriesTableFilterComposer(
            $db: $db,
            $table: $db.queueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> consultationsRefs(
    Expression<bool> Function($$ConsultationsTableFilterComposer f) f,
  ) {
    final $$ConsultationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableFilterComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> diagnosesRefs(
    Expression<bool> Function($$DiagnosesTableFilterComposer f) f,
  ) {
    final $$DiagnosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableFilterComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vitalsRefs(
    Expression<bool> Function($$VitalsTableFilterComposer f) f,
  ) {
    final $$VitalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vitals,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VitalsTableFilterComposer(
            $db: $db,
            $table: $db.vitals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prescriptionsRefs(
    Expression<bool> Function($$PrescriptionsTableFilterComposer f) f,
  ) {
    final $$PrescriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionsTableFilterComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> insuranceClaimsRefs(
    Expression<bool> Function($$InsuranceClaimsTableFilterComposer f) f,
  ) {
    final $$InsuranceClaimsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.insuranceClaims,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsuranceClaimsTableFilterComposer(
            $db: $db,
            $table: $db.insuranceClaims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smarthealthPatientId => $composableBuilder(
    column: $table.smarthealthPatientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passport => $composableBuilder(
    column: $table.passport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insuranceInfo => $composableBuilder(
    column: $table.insuranceInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get smarthealthPatientId => $composableBuilder(
    column: $table.smarthealthPatientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passport =>
      $composableBuilder(column: $table.passport, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insuranceInfo => $composableBuilder(
    column: $table.insuranceInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> patientAllergiesRefs<T extends Object>(
    Expression<T> Function($$PatientAllergiesTableAnnotationComposer a) f,
  ) {
    final $$PatientAllergiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.patientAllergies,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientAllergiesTableAnnotationComposer(
            $db: $db,
            $table: $db.patientAllergies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> patientConditionsRefs<T extends Object>(
    Expression<T> Function($$PatientConditionsTableAnnotationComposer a) f,
  ) {
    final $$PatientConditionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.patientConditions,
          getReferencedColumn: (t) => t.patientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PatientConditionsTableAnnotationComposer(
                $db: $db,
                $table: $db.patientConditions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> appointmentsRefs<T extends Object>(
    Expression<T> Function($$AppointmentsTableAnnotationComposer a) f,
  ) {
    final $$AppointmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appointments,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppointmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.appointments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> queueEntriesRefs<T extends Object>(
    Expression<T> Function($$QueueEntriesTableAnnotationComposer a) f,
  ) {
    final $$QueueEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueEntries,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.queueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> consultationsRefs<T extends Object>(
    Expression<T> Function($$ConsultationsTableAnnotationComposer a) f,
  ) {
    final $$ConsultationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableAnnotationComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> diagnosesRefs<T extends Object>(
    Expression<T> Function($$DiagnosesTableAnnotationComposer a) f,
  ) {
    final $$DiagnosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableAnnotationComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vitalsRefs<T extends Object>(
    Expression<T> Function($$VitalsTableAnnotationComposer a) f,
  ) {
    final $$VitalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vitals,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VitalsTableAnnotationComposer(
            $db: $db,
            $table: $db.vitals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prescriptionsRefs<T extends Object>(
    Expression<T> Function($$PrescriptionsTableAnnotationComposer a) f,
  ) {
    final $$PrescriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> insuranceClaimsRefs<T extends Object>(
    Expression<T> Function($$InsuranceClaimsTableAnnotationComposer a) f,
  ) {
    final $$InsuranceClaimsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.insuranceClaims,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsuranceClaimsTableAnnotationComposer(
            $db: $db,
            $table: $db.insuranceClaims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          Patient,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (Patient, $$PatientsTableReferences),
          Patient,
          PrefetchHooks Function({
            bool patientAllergiesRefs,
            bool patientConditionsRefs,
            bool appointmentsRefs,
            bool queueEntriesRefs,
            bool consultationsRefs,
            bool diagnosesRefs,
            bool vitalsRefs,
            bool prescriptionsRefs,
            bool insuranceClaimsRefs,
          })
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String?> smarthealthPatientId = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String?> passport = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> insuranceInfo = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion(
                id: id,
                serverId: serverId,
                smarthealthPatientId: smarthealthPatientId,
                nationalId: nationalId,
                passport: passport,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                email: email,
                gender: gender,
                dateOfBirth: dateOfBirth,
                insuranceInfo: insuranceInfo,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                Value<String?> smarthealthPatientId = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String?> passport = const Value.absent(),
                required String firstName,
                required String lastName,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> insuranceInfo = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                serverId: serverId,
                smarthealthPatientId: smarthealthPatientId,
                nationalId: nationalId,
                passport: passport,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                email: email,
                gender: gender,
                dateOfBirth: dateOfBirth,
                insuranceInfo: insuranceInfo,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PatientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                patientAllergiesRefs = false,
                patientConditionsRefs = false,
                appointmentsRefs = false,
                queueEntriesRefs = false,
                consultationsRefs = false,
                diagnosesRefs = false,
                vitalsRefs = false,
                prescriptionsRefs = false,
                insuranceClaimsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (patientAllergiesRefs) db.patientAllergies,
                    if (patientConditionsRefs) db.patientConditions,
                    if (appointmentsRefs) db.appointments,
                    if (queueEntriesRefs) db.queueEntries,
                    if (consultationsRefs) db.consultations,
                    if (diagnosesRefs) db.diagnoses,
                    if (vitalsRefs) db.vitals,
                    if (prescriptionsRefs) db.prescriptions,
                    if (insuranceClaimsRefs) db.insuranceClaims,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (patientAllergiesRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          PatientAllergy
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._patientAllergiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).patientAllergiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (patientConditionsRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          PatientCondition
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._patientConditionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).patientConditionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (appointmentsRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          Appointment
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._appointmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).appointmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (queueEntriesRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          QueueEntry
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._queueEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).queueEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (consultationsRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          Consultation
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._consultationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).consultationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (diagnosesRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          Diagnose
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._diagnosesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).diagnosesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vitalsRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          Vital
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._vitalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).vitalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (prescriptionsRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          Prescription
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._prescriptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).prescriptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (insuranceClaimsRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          InsuranceClaim
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._insuranceClaimsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).insuranceClaimsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      Patient,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (Patient, $$PatientsTableReferences),
      Patient,
      PrefetchHooks Function({
        bool patientAllergiesRefs,
        bool patientConditionsRefs,
        bool appointmentsRefs,
        bool queueEntriesRefs,
        bool consultationsRefs,
        bool diagnosesRefs,
        bool vitalsRefs,
        bool prescriptionsRefs,
        bool insuranceClaimsRefs,
      })
    >;
typedef $$PatientAllergiesTableCreateCompanionBuilder =
    PatientAllergiesCompanion Function({
      required String id,
      required String patientId,
      required String allergen,
      Value<String?> severity,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PatientAllergiesTableUpdateCompanionBuilder =
    PatientAllergiesCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> allergen,
      Value<String?> severity,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PatientAllergiesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PatientAllergiesTable, PatientAllergy> {
  $$PatientAllergiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('patient_allergies__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PatientAllergiesTableFilterComposer
    extends Composer<_$AppDatabase, $PatientAllergiesTable> {
  $$PatientAllergiesTableFilterComposer({
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

  ColumnFilters<String> get allergen => $composableBuilder(
    column: $table.allergen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PatientAllergiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientAllergiesTable> {
  $$PatientAllergiesTableOrderingComposer({
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

  ColumnOrderings<String> get allergen => $composableBuilder(
    column: $table.allergen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PatientAllergiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientAllergiesTable> {
  $$PatientAllergiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get allergen =>
      $composableBuilder(column: $table.allergen, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PatientAllergiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientAllergiesTable,
          PatientAllergy,
          $$PatientAllergiesTableFilterComposer,
          $$PatientAllergiesTableOrderingComposer,
          $$PatientAllergiesTableAnnotationComposer,
          $$PatientAllergiesTableCreateCompanionBuilder,
          $$PatientAllergiesTableUpdateCompanionBuilder,
          (PatientAllergy, $$PatientAllergiesTableReferences),
          PatientAllergy,
          PrefetchHooks Function({bool patientId})
        > {
  $$PatientAllergiesTableTableManager(
    _$AppDatabase db,
    $PatientAllergiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientAllergiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientAllergiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientAllergiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> allergen = const Value.absent(),
                Value<String?> severity = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientAllergiesCompanion(
                id: id,
                patientId: patientId,
                allergen: allergen,
                severity: severity,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String allergen,
                Value<String?> severity = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PatientAllergiesCompanion.insert(
                id: id,
                patientId: patientId,
                allergen: allergen,
                severity: severity,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PatientAllergiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable:
                                    $$PatientAllergiesTableReferences
                                        ._patientIdTable(db),
                                referencedColumn:
                                    $$PatientAllergiesTableReferences
                                        ._patientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PatientAllergiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientAllergiesTable,
      PatientAllergy,
      $$PatientAllergiesTableFilterComposer,
      $$PatientAllergiesTableOrderingComposer,
      $$PatientAllergiesTableAnnotationComposer,
      $$PatientAllergiesTableCreateCompanionBuilder,
      $$PatientAllergiesTableUpdateCompanionBuilder,
      (PatientAllergy, $$PatientAllergiesTableReferences),
      PatientAllergy,
      PrefetchHooks Function({bool patientId})
    >;
typedef $$PatientConditionsTableCreateCompanionBuilder =
    PatientConditionsCompanion Function({
      required String id,
      required String patientId,
      required String conditionName,
      Value<String?> icd11Code,
      Value<String> status,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PatientConditionsTableUpdateCompanionBuilder =
    PatientConditionsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> conditionName,
      Value<String?> icd11Code,
      Value<String> status,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PatientConditionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PatientConditionsTable,
          PatientCondition
        > {
  $$PatientConditionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('patient_conditions__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PatientConditionsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientConditionsTable> {
  $$PatientConditionsTableFilterComposer({
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

  ColumnFilters<String> get conditionName => $composableBuilder(
    column: $table.conditionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icd11Code => $composableBuilder(
    column: $table.icd11Code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PatientConditionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientConditionsTable> {
  $$PatientConditionsTableOrderingComposer({
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

  ColumnOrderings<String> get conditionName => $composableBuilder(
    column: $table.conditionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icd11Code => $composableBuilder(
    column: $table.icd11Code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PatientConditionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientConditionsTable> {
  $$PatientConditionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conditionName => $composableBuilder(
    column: $table.conditionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icd11Code =>
      $composableBuilder(column: $table.icd11Code, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PatientConditionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientConditionsTable,
          PatientCondition,
          $$PatientConditionsTableFilterComposer,
          $$PatientConditionsTableOrderingComposer,
          $$PatientConditionsTableAnnotationComposer,
          $$PatientConditionsTableCreateCompanionBuilder,
          $$PatientConditionsTableUpdateCompanionBuilder,
          (PatientCondition, $$PatientConditionsTableReferences),
          PatientCondition,
          PrefetchHooks Function({bool patientId})
        > {
  $$PatientConditionsTableTableManager(
    _$AppDatabase db,
    $PatientConditionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientConditionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientConditionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientConditionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> conditionName = const Value.absent(),
                Value<String?> icd11Code = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientConditionsCompanion(
                id: id,
                patientId: patientId,
                conditionName: conditionName,
                icd11Code: icd11Code,
                status: status,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String conditionName,
                Value<String?> icd11Code = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PatientConditionsCompanion.insert(
                id: id,
                patientId: patientId,
                conditionName: conditionName,
                icd11Code: icd11Code,
                status: status,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PatientConditionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable:
                                    $$PatientConditionsTableReferences
                                        ._patientIdTable(db),
                                referencedColumn:
                                    $$PatientConditionsTableReferences
                                        ._patientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PatientConditionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientConditionsTable,
      PatientCondition,
      $$PatientConditionsTableFilterComposer,
      $$PatientConditionsTableOrderingComposer,
      $$PatientConditionsTableAnnotationComposer,
      $$PatientConditionsTableCreateCompanionBuilder,
      $$PatientConditionsTableUpdateCompanionBuilder,
      (PatientCondition, $$PatientConditionsTableReferences),
      PatientCondition,
      PrefetchHooks Function({bool patientId})
    >;
typedef $$AppointmentsTableCreateCompanionBuilder =
    AppointmentsCompanion Function({
      required String id,
      Value<String?> serverId,
      required String facilityId,
      Value<String?> providerId,
      required String patientId,
      Value<String?> referenceNumber,
      required String status,
      Value<String?> appointmentType,
      required DateTime scheduledAt,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppointmentsTableUpdateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> facilityId,
      Value<String?> providerId,
      Value<String> patientId,
      Value<String?> referenceNumber,
      Value<String> status,
      Value<String?> appointmentType,
      Value<DateTime> scheduledAt,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$AppointmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment> {
  $$AppointmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FacilitiesTable _facilityIdTable(_$AppDatabase db) =>
      db.facilities.createAlias('appointments__facility_id__facilities__id');

  $$FacilitiesTableProcessedTableManager get facilityId {
    final $_column = $_itemColumn<String>('facility_id')!;

    final manager = $$FacilitiesTableTableManager(
      $_db,
      $_db.facilities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('appointments__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appointmentType => $composableBuilder(
    column: $table.appointmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FacilitiesTableFilterComposer get facilityId {
    final $$FacilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableFilterComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appointmentType => $composableBuilder(
    column: $table.appointmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacilitiesTableOrderingComposer get facilityId {
    final $$FacilitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableOrderingComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get appointmentType => $composableBuilder(
    column: $table.appointmentType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FacilitiesTableAnnotationComposer get facilityId {
    final $$FacilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppointmentsTable,
          Appointment,
          $$AppointmentsTableFilterComposer,
          $$AppointmentsTableOrderingComposer,
          $$AppointmentsTableAnnotationComposer,
          $$AppointmentsTableCreateCompanionBuilder,
          $$AppointmentsTableUpdateCompanionBuilder,
          (Appointment, $$AppointmentsTableReferences),
          Appointment,
          PrefetchHooks Function({bool facilityId, bool patientId})
        > {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> appointmentType = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppointmentsCompanion(
                id: id,
                serverId: serverId,
                facilityId: facilityId,
                providerId: providerId,
                patientId: patientId,
                referenceNumber: referenceNumber,
                status: status,
                appointmentType: appointmentType,
                scheduledAt: scheduledAt,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String facilityId,
                Value<String?> providerId = const Value.absent(),
                required String patientId,
                Value<String?> referenceNumber = const Value.absent(),
                required String status,
                Value<String?> appointmentType = const Value.absent(),
                required DateTime scheduledAt,
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppointmentsCompanion.insert(
                id: id,
                serverId: serverId,
                facilityId: facilityId,
                providerId: providerId,
                patientId: patientId,
                referenceNumber: referenceNumber,
                status: status,
                appointmentType: appointmentType,
                scheduledAt: scheduledAt,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppointmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({facilityId = false, patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (facilityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.facilityId,
                                referencedTable: $$AppointmentsTableReferences
                                    ._facilityIdTable(db),
                                referencedColumn: $$AppointmentsTableReferences
                                    ._facilityIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable: $$AppointmentsTableReferences
                                    ._patientIdTable(db),
                                referencedColumn: $$AppointmentsTableReferences
                                    ._patientIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppointmentsTable,
      Appointment,
      $$AppointmentsTableFilterComposer,
      $$AppointmentsTableOrderingComposer,
      $$AppointmentsTableAnnotationComposer,
      $$AppointmentsTableCreateCompanionBuilder,
      $$AppointmentsTableUpdateCompanionBuilder,
      (Appointment, $$AppointmentsTableReferences),
      Appointment,
      PrefetchHooks Function({bool facilityId, bool patientId})
    >;
typedef $$QueueEntriesTableCreateCompanionBuilder =
    QueueEntriesCompanion Function({
      required String id,
      Value<String?> serverId,
      required String facilityId,
      required String patientId,
      Value<String?> appointmentId,
      Value<int> position,
      required String status,
      Value<String?> triageStatus,
      required DateTime arrivedAt,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$QueueEntriesTableUpdateCompanionBuilder =
    QueueEntriesCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> facilityId,
      Value<String> patientId,
      Value<String?> appointmentId,
      Value<int> position,
      Value<String> status,
      Value<String?> triageStatus,
      Value<DateTime> arrivedAt,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$QueueEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $QueueEntriesTable, QueueEntry> {
  $$QueueEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FacilitiesTable _facilityIdTable(_$AppDatabase db) =>
      db.facilities.createAlias('queue_entries__facility_id__facilities__id');

  $$FacilitiesTableProcessedTableManager get facilityId {
    final $_column = $_itemColumn<String>('facility_id')!;

    final manager = $$FacilitiesTableTableManager(
      $_db,
      $_db.facilities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('queue_entries__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $QueueEntriesTable> {
  $$QueueEntriesTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triageStatus => $composableBuilder(
    column: $table.triageStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrivedAt => $composableBuilder(
    column: $table.arrivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FacilitiesTableFilterComposer get facilityId {
    final $$FacilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableFilterComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueEntriesTable> {
  $$QueueEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triageStatus => $composableBuilder(
    column: $table.triageStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrivedAt => $composableBuilder(
    column: $table.arrivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacilitiesTableOrderingComposer get facilityId {
    final $$FacilitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableOrderingComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueEntriesTable> {
  $$QueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get triageStatus => $composableBuilder(
    column: $table.triageStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get arrivedAt =>
      $composableBuilder(column: $table.arrivedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FacilitiesTableAnnotationComposer get facilityId {
    final $$FacilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueEntriesTable,
          QueueEntry,
          $$QueueEntriesTableFilterComposer,
          $$QueueEntriesTableOrderingComposer,
          $$QueueEntriesTableAnnotationComposer,
          $$QueueEntriesTableCreateCompanionBuilder,
          $$QueueEntriesTableUpdateCompanionBuilder,
          (QueueEntry, $$QueueEntriesTableReferences),
          QueueEntry,
          PrefetchHooks Function({bool facilityId, bool patientId})
        > {
  $$QueueEntriesTableTableManager(_$AppDatabase db, $QueueEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String?> appointmentId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> triageStatus = const Value.absent(),
                Value<DateTime> arrivedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueEntriesCompanion(
                id: id,
                serverId: serverId,
                facilityId: facilityId,
                patientId: patientId,
                appointmentId: appointmentId,
                position: position,
                status: status,
                triageStatus: triageStatus,
                arrivedAt: arrivedAt,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String facilityId,
                required String patientId,
                Value<String?> appointmentId = const Value.absent(),
                Value<int> position = const Value.absent(),
                required String status,
                Value<String?> triageStatus = const Value.absent(),
                required DateTime arrivedAt,
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QueueEntriesCompanion.insert(
                id: id,
                serverId: serverId,
                facilityId: facilityId,
                patientId: patientId,
                appointmentId: appointmentId,
                position: position,
                status: status,
                triageStatus: triageStatus,
                arrivedAt: arrivedAt,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QueueEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({facilityId = false, patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (facilityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.facilityId,
                                referencedTable: $$QueueEntriesTableReferences
                                    ._facilityIdTable(db),
                                referencedColumn: $$QueueEntriesTableReferences
                                    ._facilityIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable: $$QueueEntriesTableReferences
                                    ._patientIdTable(db),
                                referencedColumn: $$QueueEntriesTableReferences
                                    ._patientIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueEntriesTable,
      QueueEntry,
      $$QueueEntriesTableFilterComposer,
      $$QueueEntriesTableOrderingComposer,
      $$QueueEntriesTableAnnotationComposer,
      $$QueueEntriesTableCreateCompanionBuilder,
      $$QueueEntriesTableUpdateCompanionBuilder,
      (QueueEntry, $$QueueEntriesTableReferences),
      QueueEntry,
      PrefetchHooks Function({bool facilityId, bool patientId})
    >;
typedef $$ConsultationsTableCreateCompanionBuilder =
    ConsultationsCompanion Function({
      required String id,
      Value<String?> serverId,
      required String facilityId,
      required String providerId,
      required String patientId,
      Value<String?> appointmentId,
      Value<String> status,
      Value<String?> chiefComplaint,
      Value<String?> historyOfPresentIllness,
      Value<String?> pastMedicalHistory,
      Value<String?> surgicalHistory,
      Value<String?> familyHistory,
      Value<String?> socialHistory,
      Value<String?> examinationNotes,
      Value<String?> assessment,
      Value<String?> plan,
      Value<String?> followUpPlan,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ConsultationsTableUpdateCompanionBuilder =
    ConsultationsCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> facilityId,
      Value<String> providerId,
      Value<String> patientId,
      Value<String?> appointmentId,
      Value<String> status,
      Value<String?> chiefComplaint,
      Value<String?> historyOfPresentIllness,
      Value<String?> pastMedicalHistory,
      Value<String?> surgicalHistory,
      Value<String?> familyHistory,
      Value<String?> socialHistory,
      Value<String?> examinationNotes,
      Value<String?> assessment,
      Value<String?> plan,
      Value<String?> followUpPlan,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ConsultationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConsultationsTable, Consultation> {
  $$ConsultationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FacilitiesTable _facilityIdTable(_$AppDatabase db) =>
      db.facilities.createAlias('consultations__facility_id__facilities__id');

  $$FacilitiesTableProcessedTableManager get facilityId {
    final $_column = $_itemColumn<String>('facility_id')!;

    final manager = $$FacilitiesTableTableManager(
      $_db,
      $_db.facilities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('consultations__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DiagnosesTable, List<Diagnose>>
  _diagnosesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diagnoses,
    aliasName: 'consultations__id__diagnoses__consultation_id',
  );

  $$DiagnosesTableProcessedTableManager get diagnosesRefs {
    final manager = $$DiagnosesTableTableManager(
      $_db,
      $_db.diagnoses,
    ).filter((f) => f.consultationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_diagnosesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VitalsTable, List<Vital>> _vitalsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.vitals,
    aliasName: 'consultations__id__vitals__consultation_id',
  );

  $$VitalsTableProcessedTableManager get vitalsRefs {
    final manager = $$VitalsTableTableManager(
      $_db,
      $_db.vitals,
    ).filter((f) => f.consultationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vitalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrescriptionsTable, List<Prescription>>
  _prescriptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prescriptions,
    aliasName: 'consultations__id__prescriptions__consultation_id',
  );

  $$PrescriptionsTableProcessedTableManager get prescriptionsRefs {
    final manager = $$PrescriptionsTableTableManager(
      $_db,
      $_db.prescriptions,
    ).filter((f) => f.consultationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_prescriptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConsultationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConsultationsTable> {
  $$ConsultationsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get historyOfPresentIllness => $composableBuilder(
    column: $table.historyOfPresentIllness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pastMedicalHistory => $composableBuilder(
    column: $table.pastMedicalHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surgicalHistory => $composableBuilder(
    column: $table.surgicalHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyHistory => $composableBuilder(
    column: $table.familyHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get socialHistory => $composableBuilder(
    column: $table.socialHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examinationNotes => $composableBuilder(
    column: $table.examinationNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessment => $composableBuilder(
    column: $table.assessment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get followUpPlan => $composableBuilder(
    column: $table.followUpPlan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FacilitiesTableFilterComposer get facilityId {
    final $$FacilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableFilterComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> diagnosesRefs(
    Expression<bool> Function($$DiagnosesTableFilterComposer f) f,
  ) {
    final $$DiagnosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.consultationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableFilterComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vitalsRefs(
    Expression<bool> Function($$VitalsTableFilterComposer f) f,
  ) {
    final $$VitalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vitals,
      getReferencedColumn: (t) => t.consultationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VitalsTableFilterComposer(
            $db: $db,
            $table: $db.vitals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prescriptionsRefs(
    Expression<bool> Function($$PrescriptionsTableFilterComposer f) f,
  ) {
    final $$PrescriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.consultationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionsTableFilterComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConsultationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsultationsTable> {
  $$ConsultationsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get historyOfPresentIllness => $composableBuilder(
    column: $table.historyOfPresentIllness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pastMedicalHistory => $composableBuilder(
    column: $table.pastMedicalHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surgicalHistory => $composableBuilder(
    column: $table.surgicalHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyHistory => $composableBuilder(
    column: $table.familyHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get socialHistory => $composableBuilder(
    column: $table.socialHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examinationNotes => $composableBuilder(
    column: $table.examinationNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessment => $composableBuilder(
    column: $table.assessment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get followUpPlan => $composableBuilder(
    column: $table.followUpPlan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacilitiesTableOrderingComposer get facilityId {
    final $$FacilitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableOrderingComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConsultationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsultationsTable> {
  $$ConsultationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get historyOfPresentIllness => $composableBuilder(
    column: $table.historyOfPresentIllness,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pastMedicalHistory => $composableBuilder(
    column: $table.pastMedicalHistory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get surgicalHistory => $composableBuilder(
    column: $table.surgicalHistory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familyHistory => $composableBuilder(
    column: $table.familyHistory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get socialHistory => $composableBuilder(
    column: $table.socialHistory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examinationNotes => $composableBuilder(
    column: $table.examinationNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assessment => $composableBuilder(
    column: $table.assessment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<String> get followUpPlan => $composableBuilder(
    column: $table.followUpPlan,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FacilitiesTableAnnotationComposer get facilityId {
    final $$FacilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> diagnosesRefs<T extends Object>(
    Expression<T> Function($$DiagnosesTableAnnotationComposer a) f,
  ) {
    final $$DiagnosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.consultationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableAnnotationComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vitalsRefs<T extends Object>(
    Expression<T> Function($$VitalsTableAnnotationComposer a) f,
  ) {
    final $$VitalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vitals,
      getReferencedColumn: (t) => t.consultationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VitalsTableAnnotationComposer(
            $db: $db,
            $table: $db.vitals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prescriptionsRefs<T extends Object>(
    Expression<T> Function($$PrescriptionsTableAnnotationComposer a) f,
  ) {
    final $$PrescriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.consultationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConsultationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsultationsTable,
          Consultation,
          $$ConsultationsTableFilterComposer,
          $$ConsultationsTableOrderingComposer,
          $$ConsultationsTableAnnotationComposer,
          $$ConsultationsTableCreateCompanionBuilder,
          $$ConsultationsTableUpdateCompanionBuilder,
          (Consultation, $$ConsultationsTableReferences),
          Consultation,
          PrefetchHooks Function({
            bool facilityId,
            bool patientId,
            bool diagnosesRefs,
            bool vitalsRefs,
            bool prescriptionsRefs,
          })
        > {
  $$ConsultationsTableTableManager(_$AppDatabase db, $ConsultationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsultationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsultationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsultationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String?> appointmentId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> chiefComplaint = const Value.absent(),
                Value<String?> historyOfPresentIllness = const Value.absent(),
                Value<String?> pastMedicalHistory = const Value.absent(),
                Value<String?> surgicalHistory = const Value.absent(),
                Value<String?> familyHistory = const Value.absent(),
                Value<String?> socialHistory = const Value.absent(),
                Value<String?> examinationNotes = const Value.absent(),
                Value<String?> assessment = const Value.absent(),
                Value<String?> plan = const Value.absent(),
                Value<String?> followUpPlan = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsultationsCompanion(
                id: id,
                serverId: serverId,
                facilityId: facilityId,
                providerId: providerId,
                patientId: patientId,
                appointmentId: appointmentId,
                status: status,
                chiefComplaint: chiefComplaint,
                historyOfPresentIllness: historyOfPresentIllness,
                pastMedicalHistory: pastMedicalHistory,
                surgicalHistory: surgicalHistory,
                familyHistory: familyHistory,
                socialHistory: socialHistory,
                examinationNotes: examinationNotes,
                assessment: assessment,
                plan: plan,
                followUpPlan: followUpPlan,
                startedAt: startedAt,
                completedAt: completedAt,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String facilityId,
                required String providerId,
                required String patientId,
                Value<String?> appointmentId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> chiefComplaint = const Value.absent(),
                Value<String?> historyOfPresentIllness = const Value.absent(),
                Value<String?> pastMedicalHistory = const Value.absent(),
                Value<String?> surgicalHistory = const Value.absent(),
                Value<String?> familyHistory = const Value.absent(),
                Value<String?> socialHistory = const Value.absent(),
                Value<String?> examinationNotes = const Value.absent(),
                Value<String?> assessment = const Value.absent(),
                Value<String?> plan = const Value.absent(),
                Value<String?> followUpPlan = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ConsultationsCompanion.insert(
                id: id,
                serverId: serverId,
                facilityId: facilityId,
                providerId: providerId,
                patientId: patientId,
                appointmentId: appointmentId,
                status: status,
                chiefComplaint: chiefComplaint,
                historyOfPresentIllness: historyOfPresentIllness,
                pastMedicalHistory: pastMedicalHistory,
                surgicalHistory: surgicalHistory,
                familyHistory: familyHistory,
                socialHistory: socialHistory,
                examinationNotes: examinationNotes,
                assessment: assessment,
                plan: plan,
                followUpPlan: followUpPlan,
                startedAt: startedAt,
                completedAt: completedAt,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConsultationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                facilityId = false,
                patientId = false,
                diagnosesRefs = false,
                vitalsRefs = false,
                prescriptionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (diagnosesRefs) db.diagnoses,
                    if (vitalsRefs) db.vitals,
                    if (prescriptionsRefs) db.prescriptions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (facilityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.facilityId,
                                    referencedTable:
                                        $$ConsultationsTableReferences
                                            ._facilityIdTable(db),
                                    referencedColumn:
                                        $$ConsultationsTableReferences
                                            ._facilityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (patientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.patientId,
                                    referencedTable:
                                        $$ConsultationsTableReferences
                                            ._patientIdTable(db),
                                    referencedColumn:
                                        $$ConsultationsTableReferences
                                            ._patientIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (diagnosesRefs)
                        await $_getPrefetchedData<
                          Consultation,
                          $ConsultationsTable,
                          Diagnose
                        >(
                          currentTable: table,
                          referencedTable: $$ConsultationsTableReferences
                              ._diagnosesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConsultationsTableReferences(
                                db,
                                table,
                                p0,
                              ).diagnosesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.consultationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vitalsRefs)
                        await $_getPrefetchedData<
                          Consultation,
                          $ConsultationsTable,
                          Vital
                        >(
                          currentTable: table,
                          referencedTable: $$ConsultationsTableReferences
                              ._vitalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConsultationsTableReferences(
                                db,
                                table,
                                p0,
                              ).vitalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.consultationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (prescriptionsRefs)
                        await $_getPrefetchedData<
                          Consultation,
                          $ConsultationsTable,
                          Prescription
                        >(
                          currentTable: table,
                          referencedTable: $$ConsultationsTableReferences
                              ._prescriptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConsultationsTableReferences(
                                db,
                                table,
                                p0,
                              ).prescriptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.consultationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConsultationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsultationsTable,
      Consultation,
      $$ConsultationsTableFilterComposer,
      $$ConsultationsTableOrderingComposer,
      $$ConsultationsTableAnnotationComposer,
      $$ConsultationsTableCreateCompanionBuilder,
      $$ConsultationsTableUpdateCompanionBuilder,
      (Consultation, $$ConsultationsTableReferences),
      Consultation,
      PrefetchHooks Function({
        bool facilityId,
        bool patientId,
        bool diagnosesRefs,
        bool vitalsRefs,
        bool prescriptionsRefs,
      })
    >;
typedef $$DiagnosesTableCreateCompanionBuilder =
    DiagnosesCompanion Function({
      required String id,
      required String consultationId,
      required String patientId,
      required String providerId,
      required String facilityId,
      Value<String?> icd11Code,
      Value<String?> icd10Code,
      required String description,
      Value<bool> isPrimary,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DiagnosesTableUpdateCompanionBuilder =
    DiagnosesCompanion Function({
      Value<String> id,
      Value<String> consultationId,
      Value<String> patientId,
      Value<String> providerId,
      Value<String> facilityId,
      Value<String?> icd11Code,
      Value<String?> icd10Code,
      Value<String> description,
      Value<bool> isPrimary,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DiagnosesTableReferences
    extends BaseReferences<_$AppDatabase, $DiagnosesTable, Diagnose> {
  $$DiagnosesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConsultationsTable _consultationIdTable(_$AppDatabase db) => db
      .consultations
      .createAlias('diagnoses__consultation_id__consultations__id');

  $$ConsultationsTableProcessedTableManager get consultationId {
    final $_column = $_itemColumn<String>('consultation_id')!;

    final manager = $$ConsultationsTableTableManager(
      $_db,
      $_db.consultations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_consultationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('diagnoses__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DiagnosesTableFilterComposer
    extends Composer<_$AppDatabase, $DiagnosesTable> {
  $$DiagnosesTableFilterComposer({
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

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icd11Code => $composableBuilder(
    column: $table.icd11Code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icd10Code => $composableBuilder(
    column: $table.icd10Code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConsultationsTableFilterComposer get consultationId {
    final $$ConsultationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consultationId,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableFilterComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiagnosesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiagnosesTable> {
  $$DiagnosesTableOrderingComposer({
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

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icd11Code => $composableBuilder(
    column: $table.icd11Code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icd10Code => $composableBuilder(
    column: $table.icd10Code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConsultationsTableOrderingComposer get consultationId {
    final $$ConsultationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consultationId,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableOrderingComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiagnosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiagnosesTable> {
  $$DiagnosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icd11Code =>
      $composableBuilder(column: $table.icd11Code, builder: (column) => column);

  GeneratedColumn<String> get icd10Code =>
      $composableBuilder(column: $table.icd10Code, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ConsultationsTableAnnotationComposer get consultationId {
    final $$ConsultationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consultationId,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableAnnotationComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiagnosesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiagnosesTable,
          Diagnose,
          $$DiagnosesTableFilterComposer,
          $$DiagnosesTableOrderingComposer,
          $$DiagnosesTableAnnotationComposer,
          $$DiagnosesTableCreateCompanionBuilder,
          $$DiagnosesTableUpdateCompanionBuilder,
          (Diagnose, $$DiagnosesTableReferences),
          Diagnose,
          PrefetchHooks Function({bool consultationId, bool patientId})
        > {
  $$DiagnosesTableTableManager(_$AppDatabase db, $DiagnosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiagnosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> consultationId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String?> icd11Code = const Value.absent(),
                Value<String?> icd10Code = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiagnosesCompanion(
                id: id,
                consultationId: consultationId,
                patientId: patientId,
                providerId: providerId,
                facilityId: facilityId,
                icd11Code: icd11Code,
                icd10Code: icd10Code,
                description: description,
                isPrimary: isPrimary,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String consultationId,
                required String patientId,
                required String providerId,
                required String facilityId,
                Value<String?> icd11Code = const Value.absent(),
                Value<String?> icd10Code = const Value.absent(),
                required String description,
                Value<bool> isPrimary = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DiagnosesCompanion.insert(
                id: id,
                consultationId: consultationId,
                patientId: patientId,
                providerId: providerId,
                facilityId: facilityId,
                icd11Code: icd11Code,
                icd10Code: icd10Code,
                description: description,
                isPrimary: isPrimary,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DiagnosesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({consultationId = false, patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (consultationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.consultationId,
                                referencedTable: $$DiagnosesTableReferences
                                    ._consultationIdTable(db),
                                referencedColumn: $$DiagnosesTableReferences
                                    ._consultationIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable: $$DiagnosesTableReferences
                                    ._patientIdTable(db),
                                referencedColumn: $$DiagnosesTableReferences
                                    ._patientIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DiagnosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiagnosesTable,
      Diagnose,
      $$DiagnosesTableFilterComposer,
      $$DiagnosesTableOrderingComposer,
      $$DiagnosesTableAnnotationComposer,
      $$DiagnosesTableCreateCompanionBuilder,
      $$DiagnosesTableUpdateCompanionBuilder,
      (Diagnose, $$DiagnosesTableReferences),
      Diagnose,
      PrefetchHooks Function({bool consultationId, bool patientId})
    >;
typedef $$VitalsTableCreateCompanionBuilder =
    VitalsCompanion Function({
      required String id,
      required String consultationId,
      required String patientId,
      required String facilityId,
      Value<double?> temperatureCelsius,
      Value<int?> pulseBpm,
      Value<int?> bpSystolic,
      Value<int?> bpDiastolic,
      Value<int?> oxygenSaturation,
      Value<double?> weightKg,
      Value<double?> heightCm,
      required DateTime recordedAt,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$VitalsTableUpdateCompanionBuilder =
    VitalsCompanion Function({
      Value<String> id,
      Value<String> consultationId,
      Value<String> patientId,
      Value<String> facilityId,
      Value<double?> temperatureCelsius,
      Value<int?> pulseBpm,
      Value<int?> bpSystolic,
      Value<int?> bpDiastolic,
      Value<int?> oxygenSaturation,
      Value<double?> weightKg,
      Value<double?> heightCm,
      Value<DateTime> recordedAt,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$VitalsTableReferences
    extends BaseReferences<_$AppDatabase, $VitalsTable, Vital> {
  $$VitalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConsultationsTable _consultationIdTable(_$AppDatabase db) => db
      .consultations
      .createAlias('vitals__consultation_id__consultations__id');

  $$ConsultationsTableProcessedTableManager get consultationId {
    final $_column = $_itemColumn<String>('consultation_id')!;

    final manager = $$ConsultationsTableTableManager(
      $_db,
      $_db.consultations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_consultationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('vitals__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VitalsTableFilterComposer
    extends Composer<_$AppDatabase, $VitalsTable> {
  $$VitalsTableFilterComposer({
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

  ColumnFilters<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pulseBpm => $composableBuilder(
    column: $table.pulseBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bpSystolic => $composableBuilder(
    column: $table.bpSystolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bpDiastolic => $composableBuilder(
    column: $table.bpDiastolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oxygenSaturation => $composableBuilder(
    column: $table.oxygenSaturation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConsultationsTableFilterComposer get consultationId {
    final $$ConsultationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consultationId,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableFilterComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VitalsTableOrderingComposer
    extends Composer<_$AppDatabase, $VitalsTable> {
  $$VitalsTableOrderingComposer({
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

  ColumnOrderings<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pulseBpm => $composableBuilder(
    column: $table.pulseBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bpSystolic => $composableBuilder(
    column: $table.bpSystolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bpDiastolic => $composableBuilder(
    column: $table.bpDiastolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oxygenSaturation => $composableBuilder(
    column: $table.oxygenSaturation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConsultationsTableOrderingComposer get consultationId {
    final $$ConsultationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consultationId,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableOrderingComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VitalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VitalsTable> {
  $$VitalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pulseBpm =>
      $composableBuilder(column: $table.pulseBpm, builder: (column) => column);

  GeneratedColumn<int> get bpSystolic => $composableBuilder(
    column: $table.bpSystolic,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bpDiastolic => $composableBuilder(
    column: $table.bpDiastolic,
    builder: (column) => column,
  );

  GeneratedColumn<int> get oxygenSaturation => $composableBuilder(
    column: $table.oxygenSaturation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ConsultationsTableAnnotationComposer get consultationId {
    final $$ConsultationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consultationId,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableAnnotationComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VitalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VitalsTable,
          Vital,
          $$VitalsTableFilterComposer,
          $$VitalsTableOrderingComposer,
          $$VitalsTableAnnotationComposer,
          $$VitalsTableCreateCompanionBuilder,
          $$VitalsTableUpdateCompanionBuilder,
          (Vital, $$VitalsTableReferences),
          Vital,
          PrefetchHooks Function({bool consultationId, bool patientId})
        > {
  $$VitalsTableTableManager(_$AppDatabase db, $VitalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VitalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VitalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VitalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> consultationId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<double?> temperatureCelsius = const Value.absent(),
                Value<int?> pulseBpm = const Value.absent(),
                Value<int?> bpSystolic = const Value.absent(),
                Value<int?> bpDiastolic = const Value.absent(),
                Value<int?> oxygenSaturation = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VitalsCompanion(
                id: id,
                consultationId: consultationId,
                patientId: patientId,
                facilityId: facilityId,
                temperatureCelsius: temperatureCelsius,
                pulseBpm: pulseBpm,
                bpSystolic: bpSystolic,
                bpDiastolic: bpDiastolic,
                oxygenSaturation: oxygenSaturation,
                weightKg: weightKg,
                heightCm: heightCm,
                recordedAt: recordedAt,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String consultationId,
                required String patientId,
                required String facilityId,
                Value<double?> temperatureCelsius = const Value.absent(),
                Value<int?> pulseBpm = const Value.absent(),
                Value<int?> bpSystolic = const Value.absent(),
                Value<int?> bpDiastolic = const Value.absent(),
                Value<int?> oxygenSaturation = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                required DateTime recordedAt,
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VitalsCompanion.insert(
                id: id,
                consultationId: consultationId,
                patientId: patientId,
                facilityId: facilityId,
                temperatureCelsius: temperatureCelsius,
                pulseBpm: pulseBpm,
                bpSystolic: bpSystolic,
                bpDiastolic: bpDiastolic,
                oxygenSaturation: oxygenSaturation,
                weightKg: weightKg,
                heightCm: heightCm,
                recordedAt: recordedAt,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VitalsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({consultationId = false, patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (consultationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.consultationId,
                                referencedTable: $$VitalsTableReferences
                                    ._consultationIdTable(db),
                                referencedColumn: $$VitalsTableReferences
                                    ._consultationIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable: $$VitalsTableReferences
                                    ._patientIdTable(db),
                                referencedColumn: $$VitalsTableReferences
                                    ._patientIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VitalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VitalsTable,
      Vital,
      $$VitalsTableFilterComposer,
      $$VitalsTableOrderingComposer,
      $$VitalsTableAnnotationComposer,
      $$VitalsTableCreateCompanionBuilder,
      $$VitalsTableUpdateCompanionBuilder,
      (Vital, $$VitalsTableReferences),
      Vital,
      PrefetchHooks Function({bool consultationId, bool patientId})
    >;
typedef $$PrescriptionsTableCreateCompanionBuilder =
    PrescriptionsCompanion Function({
      required String id,
      Value<String?> serverId,
      required String consultationId,
      required String patientId,
      required String providerId,
      required String facilityId,
      required String medication,
      Value<String?> dosage,
      Value<String?> frequency,
      Value<String?> duration,
      Value<String?> instructions,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PrescriptionsTableUpdateCompanionBuilder =
    PrescriptionsCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> consultationId,
      Value<String> patientId,
      Value<String> providerId,
      Value<String> facilityId,
      Value<String> medication,
      Value<String?> dosage,
      Value<String?> frequency,
      Value<String?> duration,
      Value<String?> instructions,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PrescriptionsTableReferences
    extends BaseReferences<_$AppDatabase, $PrescriptionsTable, Prescription> {
  $$PrescriptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ConsultationsTable _consultationIdTable(_$AppDatabase db) => db
      .consultations
      .createAlias('prescriptions__consultation_id__consultations__id');

  $$ConsultationsTableProcessedTableManager get consultationId {
    final $_column = $_itemColumn<String>('consultation_id')!;

    final manager = $$ConsultationsTableTableManager(
      $_db,
      $_db.consultations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_consultationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('prescriptions__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrescriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medication => $composableBuilder(
    column: $table.medication,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConsultationsTableFilterComposer get consultationId {
    final $$ConsultationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consultationId,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableFilterComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medication => $composableBuilder(
    column: $table.medication,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConsultationsTableOrderingComposer get consultationId {
    final $$ConsultationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consultationId,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableOrderingComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medication => $composableBuilder(
    column: $table.medication,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ConsultationsTableAnnotationComposer get consultationId {
    final $$ConsultationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consultationId,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableAnnotationComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrescriptionsTable,
          Prescription,
          $$PrescriptionsTableFilterComposer,
          $$PrescriptionsTableOrderingComposer,
          $$PrescriptionsTableAnnotationComposer,
          $$PrescriptionsTableCreateCompanionBuilder,
          $$PrescriptionsTableUpdateCompanionBuilder,
          (Prescription, $$PrescriptionsTableReferences),
          Prescription,
          PrefetchHooks Function({bool consultationId, bool patientId})
        > {
  $$PrescriptionsTableTableManager(_$AppDatabase db, $PrescriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrescriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrescriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrescriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> consultationId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String> medication = const Value.absent(),
                Value<String?> dosage = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String?> duration = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrescriptionsCompanion(
                id: id,
                serverId: serverId,
                consultationId: consultationId,
                patientId: patientId,
                providerId: providerId,
                facilityId: facilityId,
                medication: medication,
                dosage: dosage,
                frequency: frequency,
                duration: duration,
                instructions: instructions,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String consultationId,
                required String patientId,
                required String providerId,
                required String facilityId,
                required String medication,
                Value<String?> dosage = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String?> duration = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PrescriptionsCompanion.insert(
                id: id,
                serverId: serverId,
                consultationId: consultationId,
                patientId: patientId,
                providerId: providerId,
                facilityId: facilityId,
                medication: medication,
                dosage: dosage,
                frequency: frequency,
                duration: duration,
                instructions: instructions,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrescriptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({consultationId = false, patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (consultationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.consultationId,
                                referencedTable: $$PrescriptionsTableReferences
                                    ._consultationIdTable(db),
                                referencedColumn: $$PrescriptionsTableReferences
                                    ._consultationIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable: $$PrescriptionsTableReferences
                                    ._patientIdTable(db),
                                referencedColumn: $$PrescriptionsTableReferences
                                    ._patientIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PrescriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrescriptionsTable,
      Prescription,
      $$PrescriptionsTableFilterComposer,
      $$PrescriptionsTableOrderingComposer,
      $$PrescriptionsTableAnnotationComposer,
      $$PrescriptionsTableCreateCompanionBuilder,
      $$PrescriptionsTableUpdateCompanionBuilder,
      (Prescription, $$PrescriptionsTableReferences),
      Prescription,
      PrefetchHooks Function({bool consultationId, bool patientId})
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      required String operation,
      required String payloadJson,
      Value<int> retryCount,
      required DateTime createdAt,
      Value<DateTime?> lastAttemptAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> lastAttemptAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required String operation,
                required String payloadJson,
                Value<int> retryCount = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastAttemptAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String entityType,
      required String facilityId,
      required DateTime lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> entityType,
      Value<String> facilityId,
      Value<DateTime> lastSyncedAt,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                entityType: entityType,
                facilityId: facilityId,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String facilityId,
                required DateTime lastSyncedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                entityType: entityType,
                facilityId: facilityId,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$FeatureFlagsTableCreateCompanionBuilder =
    FeatureFlagsCompanion Function({
      required String key,
      Value<bool> enabled,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FeatureFlagsTableUpdateCompanionBuilder =
    FeatureFlagsCompanion Function({
      Value<String> key,
      Value<bool> enabled,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FeatureFlagsTableFilterComposer
    extends Composer<_$AppDatabase, $FeatureFlagsTable> {
  $$FeatureFlagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeatureFlagsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeatureFlagsTable> {
  $$FeatureFlagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeatureFlagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeatureFlagsTable> {
  $$FeatureFlagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeatureFlagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeatureFlagsTable,
          FeatureFlag,
          $$FeatureFlagsTableFilterComposer,
          $$FeatureFlagsTableOrderingComposer,
          $$FeatureFlagsTableAnnotationComposer,
          $$FeatureFlagsTableCreateCompanionBuilder,
          $$FeatureFlagsTableUpdateCompanionBuilder,
          (
            FeatureFlag,
            BaseReferences<_$AppDatabase, $FeatureFlagsTable, FeatureFlag>,
          ),
          FeatureFlag,
          PrefetchHooks Function()
        > {
  $$FeatureFlagsTableTableManager(_$AppDatabase db, $FeatureFlagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeatureFlagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeatureFlagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeatureFlagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeatureFlagsCompanion(
                key: key,
                enabled: enabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<bool> enabled = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FeatureFlagsCompanion.insert(
                key: key,
                enabled: enabled,
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

typedef $$FeatureFlagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeatureFlagsTable,
      FeatureFlag,
      $$FeatureFlagsTableFilterComposer,
      $$FeatureFlagsTableOrderingComposer,
      $$FeatureFlagsTableAnnotationComposer,
      $$FeatureFlagsTableCreateCompanionBuilder,
      $$FeatureFlagsTableUpdateCompanionBuilder,
      (
        FeatureFlag,
        BaseReferences<_$AppDatabase, $FeatureFlagsTable, FeatureFlag>,
      ),
      FeatureFlag,
      PrefetchHooks Function()
    >;
typedef $$Icd11CodesTableCreateCompanionBuilder =
    Icd11CodesCompanion Function({
      required String code,
      required String description,
      Value<bool> isFavorite,
      Value<int> useCount,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });
typedef $$Icd11CodesTableUpdateCompanionBuilder =
    Icd11CodesCompanion Function({
      Value<String> code,
      Value<String> description,
      Value<bool> isFavorite,
      Value<int> useCount,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });

class $$Icd11CodesTableFilterComposer
    extends Composer<_$AppDatabase, $Icd11CodesTable> {
  $$Icd11CodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get useCount => $composableBuilder(
    column: $table.useCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$Icd11CodesTableOrderingComposer
    extends Composer<_$AppDatabase, $Icd11CodesTable> {
  $$Icd11CodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get useCount => $composableBuilder(
    column: $table.useCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$Icd11CodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $Icd11CodesTable> {
  $$Icd11CodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get useCount =>
      $composableBuilder(column: $table.useCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$Icd11CodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $Icd11CodesTable,
          Icd11Code,
          $$Icd11CodesTableFilterComposer,
          $$Icd11CodesTableOrderingComposer,
          $$Icd11CodesTableAnnotationComposer,
          $$Icd11CodesTableCreateCompanionBuilder,
          $$Icd11CodesTableUpdateCompanionBuilder,
          (
            Icd11Code,
            BaseReferences<_$AppDatabase, $Icd11CodesTable, Icd11Code>,
          ),
          Icd11Code,
          PrefetchHooks Function()
        > {
  $$Icd11CodesTableTableManager(_$AppDatabase db, $Icd11CodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$Icd11CodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$Icd11CodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$Icd11CodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> useCount = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => Icd11CodesCompanion(
                code: code,
                description: description,
                isFavorite: isFavorite,
                useCount: useCount,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String description,
                Value<bool> isFavorite = const Value.absent(),
                Value<int> useCount = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => Icd11CodesCompanion.insert(
                code: code,
                description: description,
                isFavorite: isFavorite,
                useCount: useCount,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$Icd11CodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $Icd11CodesTable,
      Icd11Code,
      $$Icd11CodesTableFilterComposer,
      $$Icd11CodesTableOrderingComposer,
      $$Icd11CodesTableAnnotationComposer,
      $$Icd11CodesTableCreateCompanionBuilder,
      $$Icd11CodesTableUpdateCompanionBuilder,
      (Icd11Code, BaseReferences<_$AppDatabase, $Icd11CodesTable, Icd11Code>),
      Icd11Code,
      PrefetchHooks Function()
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      required String id,
      required String name,
      Value<String?> formulation,
      Value<String?> defaultDosage,
      Value<int> rowid,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> formulation,
      Value<String?> defaultDosage,
      Value<int> rowid,
    });

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formulation => $composableBuilder(
    column: $table.formulation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultDosage => $composableBuilder(
    column: $table.defaultDosage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formulation => $composableBuilder(
    column: $table.formulation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultDosage => $composableBuilder(
    column: $table.defaultDosage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get formulation => $composableBuilder(
    column: $table.formulation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultDosage => $composableBuilder(
    column: $table.defaultDosage,
    builder: (column) => column,
  );
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (
            Medication,
            BaseReferences<_$AppDatabase, $MedicationsTable, Medication>,
          ),
          Medication,
          PrefetchHooks Function()
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> formulation = const Value.absent(),
                Value<String?> defaultDosage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                name: name,
                formulation: formulation,
                defaultDosage: defaultDosage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> formulation = const Value.absent(),
                Value<String?> defaultDosage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                name: name,
                formulation: formulation,
                defaultDosage: defaultDosage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (
        Medication,
        BaseReferences<_$AppDatabase, $MedicationsTable, Medication>,
      ),
      Medication,
      PrefetchHooks Function()
    >;
typedef $$EdlizRecommendationsTableCreateCompanionBuilder =
    EdlizRecommendationsCompanion Function({
      required String id,
      required String icd11Code,
      required String firstLine,
      Value<String?> alternative,
      Value<String?> dosage,
      Value<String?> formulation,
      Value<int> rowid,
    });
typedef $$EdlizRecommendationsTableUpdateCompanionBuilder =
    EdlizRecommendationsCompanion Function({
      Value<String> id,
      Value<String> icd11Code,
      Value<String> firstLine,
      Value<String?> alternative,
      Value<String?> dosage,
      Value<String?> formulation,
      Value<int> rowid,
    });

class $$EdlizRecommendationsTableFilterComposer
    extends Composer<_$AppDatabase, $EdlizRecommendationsTable> {
  $$EdlizRecommendationsTableFilterComposer({
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

  ColumnFilters<String> get icd11Code => $composableBuilder(
    column: $table.icd11Code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstLine => $composableBuilder(
    column: $table.firstLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternative => $composableBuilder(
    column: $table.alternative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formulation => $composableBuilder(
    column: $table.formulation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EdlizRecommendationsTableOrderingComposer
    extends Composer<_$AppDatabase, $EdlizRecommendationsTable> {
  $$EdlizRecommendationsTableOrderingComposer({
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

  ColumnOrderings<String> get icd11Code => $composableBuilder(
    column: $table.icd11Code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstLine => $composableBuilder(
    column: $table.firstLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternative => $composableBuilder(
    column: $table.alternative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formulation => $composableBuilder(
    column: $table.formulation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EdlizRecommendationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EdlizRecommendationsTable> {
  $$EdlizRecommendationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get icd11Code =>
      $composableBuilder(column: $table.icd11Code, builder: (column) => column);

  GeneratedColumn<String> get firstLine =>
      $composableBuilder(column: $table.firstLine, builder: (column) => column);

  GeneratedColumn<String> get alternative => $composableBuilder(
    column: $table.alternative,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get formulation => $composableBuilder(
    column: $table.formulation,
    builder: (column) => column,
  );
}

class $$EdlizRecommendationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EdlizRecommendationsTable,
          EdlizRecommendation,
          $$EdlizRecommendationsTableFilterComposer,
          $$EdlizRecommendationsTableOrderingComposer,
          $$EdlizRecommendationsTableAnnotationComposer,
          $$EdlizRecommendationsTableCreateCompanionBuilder,
          $$EdlizRecommendationsTableUpdateCompanionBuilder,
          (
            EdlizRecommendation,
            BaseReferences<
              _$AppDatabase,
              $EdlizRecommendationsTable,
              EdlizRecommendation
            >,
          ),
          EdlizRecommendation,
          PrefetchHooks Function()
        > {
  $$EdlizRecommendationsTableTableManager(
    _$AppDatabase db,
    $EdlizRecommendationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EdlizRecommendationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EdlizRecommendationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EdlizRecommendationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> icd11Code = const Value.absent(),
                Value<String> firstLine = const Value.absent(),
                Value<String?> alternative = const Value.absent(),
                Value<String?> dosage = const Value.absent(),
                Value<String?> formulation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EdlizRecommendationsCompanion(
                id: id,
                icd11Code: icd11Code,
                firstLine: firstLine,
                alternative: alternative,
                dosage: dosage,
                formulation: formulation,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String icd11Code,
                required String firstLine,
                Value<String?> alternative = const Value.absent(),
                Value<String?> dosage = const Value.absent(),
                Value<String?> formulation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EdlizRecommendationsCompanion.insert(
                id: id,
                icd11Code: icd11Code,
                firstLine: firstLine,
                alternative: alternative,
                dosage: dosage,
                formulation: formulation,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EdlizRecommendationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EdlizRecommendationsTable,
      EdlizRecommendation,
      $$EdlizRecommendationsTableFilterComposer,
      $$EdlizRecommendationsTableOrderingComposer,
      $$EdlizRecommendationsTableAnnotationComposer,
      $$EdlizRecommendationsTableCreateCompanionBuilder,
      $$EdlizRecommendationsTableUpdateCompanionBuilder,
      (
        EdlizRecommendation,
        BaseReferences<
          _$AppDatabase,
          $EdlizRecommendationsTable,
          EdlizRecommendation
        >,
      ),
      EdlizRecommendation,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      required String id,
      required String action,
      Value<String?> subjectId,
      Value<String?> facilityId,
      Value<String?> providerId,
      Value<String> detailsJson,
      required DateTime createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<String> id,
      Value<String> action,
      Value<String?> subjectId,
      Value<String?> facilityId,
      Value<String?> providerId,
      Value<String> detailsJson,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
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

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
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

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String?> facilityId = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                action: action,
                subjectId: subjectId,
                facilityId: facilityId,
                providerId: providerId,
                detailsJson: detailsJson,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String action,
                Value<String?> subjectId = const Value.absent(),
                Value<String?> facilityId = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                required DateTime createdAt,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                action: action,
                subjectId: subjectId,
                facilityId: facilityId,
                providerId: providerId,
                detailsJson: detailsJson,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$InsuranceClaimsTableCreateCompanionBuilder =
    InsuranceClaimsCompanion Function({
      required String id,
      Value<String?> serverId,
      required String facilityId,
      required String patientId,
      required String providerId,
      required String payerKey,
      required String status,
      Value<double> amount,
      Value<double> amountPaid,
      Value<DateTime?> submittedAt,
      Value<String> syncStatus,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$InsuranceClaimsTableUpdateCompanionBuilder =
    InsuranceClaimsCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> facilityId,
      Value<String> patientId,
      Value<String> providerId,
      Value<String> payerKey,
      Value<String> status,
      Value<double> amount,
      Value<double> amountPaid,
      Value<DateTime?> submittedAt,
      Value<String> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$InsuranceClaimsTableReferences
    extends
        BaseReferences<_$AppDatabase, $InsuranceClaimsTable, InsuranceClaim> {
  $$InsuranceClaimsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FacilitiesTable _facilityIdTable(_$AppDatabase db) => db.facilities
      .createAlias('insurance_claims__facility_id__facilities__id');

  $$FacilitiesTableProcessedTableManager get facilityId {
    final $_column = $_itemColumn<String>('facility_id')!;

    final manager = $$FacilitiesTableTableManager(
      $_db,
      $_db.facilities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('insurance_claims__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InsuranceClaimsTableFilterComposer
    extends Composer<_$AppDatabase, $InsuranceClaimsTable> {
  $$InsuranceClaimsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payerKey => $composableBuilder(
    column: $table.payerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FacilitiesTableFilterComposer get facilityId {
    final $$FacilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableFilterComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InsuranceClaimsTableOrderingComposer
    extends Composer<_$AppDatabase, $InsuranceClaimsTable> {
  $$InsuranceClaimsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payerKey => $composableBuilder(
    column: $table.payerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacilitiesTableOrderingComposer get facilityId {
    final $$FacilitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableOrderingComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InsuranceClaimsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsuranceClaimsTable> {
  $$InsuranceClaimsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payerKey =>
      $composableBuilder(column: $table.payerKey, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FacilitiesTableAnnotationComposer get facilityId {
    final $$FacilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InsuranceClaimsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InsuranceClaimsTable,
          InsuranceClaim,
          $$InsuranceClaimsTableFilterComposer,
          $$InsuranceClaimsTableOrderingComposer,
          $$InsuranceClaimsTableAnnotationComposer,
          $$InsuranceClaimsTableCreateCompanionBuilder,
          $$InsuranceClaimsTableUpdateCompanionBuilder,
          (InsuranceClaim, $$InsuranceClaimsTableReferences),
          InsuranceClaim,
          PrefetchHooks Function({bool facilityId, bool patientId})
        > {
  $$InsuranceClaimsTableTableManager(
    _$AppDatabase db,
    $InsuranceClaimsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsuranceClaimsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsuranceClaimsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsuranceClaimsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> payerKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsuranceClaimsCompanion(
                id: id,
                serverId: serverId,
                facilityId: facilityId,
                patientId: patientId,
                providerId: providerId,
                payerKey: payerKey,
                status: status,
                amount: amount,
                amountPaid: amountPaid,
                submittedAt: submittedAt,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String facilityId,
                required String patientId,
                required String providerId,
                required String payerKey,
                required String status,
                Value<double> amount = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => InsuranceClaimsCompanion.insert(
                id: id,
                serverId: serverId,
                facilityId: facilityId,
                patientId: patientId,
                providerId: providerId,
                payerKey: payerKey,
                status: status,
                amount: amount,
                amountPaid: amountPaid,
                submittedAt: submittedAt,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InsuranceClaimsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({facilityId = false, patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (facilityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.facilityId,
                                referencedTable:
                                    $$InsuranceClaimsTableReferences
                                        ._facilityIdTable(db),
                                referencedColumn:
                                    $$InsuranceClaimsTableReferences
                                        ._facilityIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable:
                                    $$InsuranceClaimsTableReferences
                                        ._patientIdTable(db),
                                referencedColumn:
                                    $$InsuranceClaimsTableReferences
                                        ._patientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InsuranceClaimsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InsuranceClaimsTable,
      InsuranceClaim,
      $$InsuranceClaimsTableFilterComposer,
      $$InsuranceClaimsTableOrderingComposer,
      $$InsuranceClaimsTableAnnotationComposer,
      $$InsuranceClaimsTableCreateCompanionBuilder,
      $$InsuranceClaimsTableUpdateCompanionBuilder,
      (InsuranceClaim, $$InsuranceClaimsTableReferences),
      InsuranceClaim,
      PrefetchHooks Function({bool facilityId, bool patientId})
    >;
typedef $$ClinicalTasksTableCreateCompanionBuilder =
    ClinicalTasksCompanion Function({
      required String id,
      required String facilityId,
      Value<String?> assigneeId,
      Value<String?> patientId,
      required String title,
      required String taskType,
      Value<String> status,
      Value<DateTime?> dueAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ClinicalTasksTableUpdateCompanionBuilder =
    ClinicalTasksCompanion Function({
      Value<String> id,
      Value<String> facilityId,
      Value<String?> assigneeId,
      Value<String?> patientId,
      Value<String> title,
      Value<String> taskType,
      Value<String> status,
      Value<DateTime?> dueAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ClinicalTasksTableReferences
    extends BaseReferences<_$AppDatabase, $ClinicalTasksTable, ClinicalTask> {
  $$ClinicalTasksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FacilitiesTable _facilityIdTable(_$AppDatabase db) =>
      db.facilities.createAlias('clinical_tasks__facility_id__facilities__id');

  $$FacilitiesTableProcessedTableManager get facilityId {
    final $_column = $_itemColumn<String>('facility_id')!;

    final manager = $$FacilitiesTableTableManager(
      $_db,
      $_db.facilities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClinicalTasksTableFilterComposer
    extends Composer<_$AppDatabase, $ClinicalTasksTable> {
  $$ClinicalTasksTableFilterComposer({
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

  ColumnFilters<String> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FacilitiesTableFilterComposer get facilityId {
    final $$FacilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableFilterComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $ClinicalTasksTable> {
  $$ClinicalTasksTableOrderingComposer({
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

  ColumnOrderings<String> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacilitiesTableOrderingComposer get facilityId {
    final $$FacilitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableOrderingComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClinicalTasksTable> {
  $$ClinicalTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FacilitiesTableAnnotationComposer get facilityId {
    final $$FacilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClinicalTasksTable,
          ClinicalTask,
          $$ClinicalTasksTableFilterComposer,
          $$ClinicalTasksTableOrderingComposer,
          $$ClinicalTasksTableAnnotationComposer,
          $$ClinicalTasksTableCreateCompanionBuilder,
          $$ClinicalTasksTableUpdateCompanionBuilder,
          (ClinicalTask, $$ClinicalTasksTableReferences),
          ClinicalTask,
          PrefetchHooks Function({bool facilityId})
        > {
  $$ClinicalTasksTableTableManager(_$AppDatabase db, $ClinicalTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClinicalTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClinicalTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClinicalTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String?> assigneeId = const Value.absent(),
                Value<String?> patientId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> taskType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalTasksCompanion(
                id: id,
                facilityId: facilityId,
                assigneeId: assigneeId,
                patientId: patientId,
                title: title,
                taskType: taskType,
                status: status,
                dueAt: dueAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String facilityId,
                Value<String?> assigneeId = const Value.absent(),
                Value<String?> patientId = const Value.absent(),
                required String title,
                required String taskType,
                Value<String> status = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ClinicalTasksCompanion.insert(
                id: id,
                facilityId: facilityId,
                assigneeId: assigneeId,
                patientId: patientId,
                title: title,
                taskType: taskType,
                status: status,
                dueAt: dueAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClinicalTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({facilityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (facilityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.facilityId,
                                referencedTable: $$ClinicalTasksTableReferences
                                    ._facilityIdTable(db),
                                referencedColumn: $$ClinicalTasksTableReferences
                                    ._facilityIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClinicalTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClinicalTasksTable,
      ClinicalTask,
      $$ClinicalTasksTableFilterComposer,
      $$ClinicalTasksTableOrderingComposer,
      $$ClinicalTasksTableAnnotationComposer,
      $$ClinicalTasksTableCreateCompanionBuilder,
      $$ClinicalTasksTableUpdateCompanionBuilder,
      (ClinicalTask, $$ClinicalTasksTableReferences),
      ClinicalTask,
      PrefetchHooks Function({bool facilityId})
    >;
typedef $$InternalMessagesTableCreateCompanionBuilder =
    InternalMessagesCompanion Function({
      required String id,
      required String facilityId,
      required String senderId,
      required String recipientId,
      required String body,
      required DateTime sentAt,
      Value<bool> read,
      Value<int> rowid,
    });
typedef $$InternalMessagesTableUpdateCompanionBuilder =
    InternalMessagesCompanion Function({
      Value<String> id,
      Value<String> facilityId,
      Value<String> senderId,
      Value<String> recipientId,
      Value<String> body,
      Value<DateTime> sentAt,
      Value<bool> read,
      Value<int> rowid,
    });

final class $$InternalMessagesTableReferences
    extends
        BaseReferences<_$AppDatabase, $InternalMessagesTable, InternalMessage> {
  $$InternalMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FacilitiesTable _facilityIdTable(_$AppDatabase db) => db.facilities
      .createAlias('internal_messages__facility_id__facilities__id');

  $$FacilitiesTableProcessedTableManager get facilityId {
    final $_column = $_itemColumn<String>('facility_id')!;

    final manager = $$FacilitiesTableTableManager(
      $_db,
      $_db.facilities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InternalMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $InternalMessagesTable> {
  $$InternalMessagesTableFilterComposer({
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

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipientId => $composableBuilder(
    column: $table.recipientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnFilters(column),
  );

  $$FacilitiesTableFilterComposer get facilityId {
    final $$FacilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableFilterComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InternalMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $InternalMessagesTable> {
  $$InternalMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipientId => $composableBuilder(
    column: $table.recipientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacilitiesTableOrderingComposer get facilityId {
    final $$FacilitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableOrderingComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InternalMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InternalMessagesTable> {
  $$InternalMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get recipientId => $composableBuilder(
    column: $table.recipientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  $$FacilitiesTableAnnotationComposer get facilityId {
    final $$FacilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InternalMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InternalMessagesTable,
          InternalMessage,
          $$InternalMessagesTableFilterComposer,
          $$InternalMessagesTableOrderingComposer,
          $$InternalMessagesTableAnnotationComposer,
          $$InternalMessagesTableCreateCompanionBuilder,
          $$InternalMessagesTableUpdateCompanionBuilder,
          (InternalMessage, $$InternalMessagesTableReferences),
          InternalMessage,
          PrefetchHooks Function({bool facilityId})
        > {
  $$InternalMessagesTableTableManager(
    _$AppDatabase db,
    $InternalMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InternalMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InternalMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InternalMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> recipientId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InternalMessagesCompanion(
                id: id,
                facilityId: facilityId,
                senderId: senderId,
                recipientId: recipientId,
                body: body,
                sentAt: sentAt,
                read: read,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String facilityId,
                required String senderId,
                required String recipientId,
                required String body,
                required DateTime sentAt,
                Value<bool> read = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InternalMessagesCompanion.insert(
                id: id,
                facilityId: facilityId,
                senderId: senderId,
                recipientId: recipientId,
                body: body,
                sentAt: sentAt,
                read: read,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InternalMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({facilityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (facilityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.facilityId,
                                referencedTable:
                                    $$InternalMessagesTableReferences
                                        ._facilityIdTable(db),
                                referencedColumn:
                                    $$InternalMessagesTableReferences
                                        ._facilityIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InternalMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InternalMessagesTable,
      InternalMessage,
      $$InternalMessagesTableFilterComposer,
      $$InternalMessagesTableOrderingComposer,
      $$InternalMessagesTableAnnotationComposer,
      $$InternalMessagesTableCreateCompanionBuilder,
      $$InternalMessagesTableUpdateCompanionBuilder,
      (InternalMessage, $$InternalMessagesTableReferences),
      InternalMessage,
      PrefetchHooks Function({bool facilityId})
    >;
typedef $$PractitionerCredentialsTableCreateCompanionBuilder =
    PractitionerCredentialsCompanion Function({
      required String id,
      required String providerId,
      required String credentialType,
      required String title,
      Value<DateTime?> issuedAt,
      Value<DateTime?> expiresAt,
      Value<String?> storagePath,
      Value<int> rowid,
    });
typedef $$PractitionerCredentialsTableUpdateCompanionBuilder =
    PractitionerCredentialsCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> credentialType,
      Value<String> title,
      Value<DateTime?> issuedAt,
      Value<DateTime?> expiresAt,
      Value<String?> storagePath,
      Value<int> rowid,
    });

class $$PractitionerCredentialsTableFilterComposer
    extends Composer<_$AppDatabase, $PractitionerCredentialsTable> {
  $$PractitionerCredentialsTableFilterComposer({
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

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get credentialType => $composableBuilder(
    column: $table.credentialType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PractitionerCredentialsTableOrderingComposer
    extends Composer<_$AppDatabase, $PractitionerCredentialsTable> {
  $$PractitionerCredentialsTableOrderingComposer({
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

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get credentialType => $composableBuilder(
    column: $table.credentialType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PractitionerCredentialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PractitionerCredentialsTable> {
  $$PractitionerCredentialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get credentialType => $composableBuilder(
    column: $table.credentialType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );
}

class $$PractitionerCredentialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PractitionerCredentialsTable,
          PractitionerCredential,
          $$PractitionerCredentialsTableFilterComposer,
          $$PractitionerCredentialsTableOrderingComposer,
          $$PractitionerCredentialsTableAnnotationComposer,
          $$PractitionerCredentialsTableCreateCompanionBuilder,
          $$PractitionerCredentialsTableUpdateCompanionBuilder,
          (
            PractitionerCredential,
            BaseReferences<
              _$AppDatabase,
              $PractitionerCredentialsTable,
              PractitionerCredential
            >,
          ),
          PractitionerCredential,
          PrefetchHooks Function()
        > {
  $$PractitionerCredentialsTableTableManager(
    _$AppDatabase db,
    $PractitionerCredentialsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PractitionerCredentialsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PractitionerCredentialsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PractitionerCredentialsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> credentialType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> issuedAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String?> storagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PractitionerCredentialsCompanion(
                id: id,
                providerId: providerId,
                credentialType: credentialType,
                title: title,
                issuedAt: issuedAt,
                expiresAt: expiresAt,
                storagePath: storagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerId,
                required String credentialType,
                required String title,
                Value<DateTime?> issuedAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String?> storagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PractitionerCredentialsCompanion.insert(
                id: id,
                providerId: providerId,
                credentialType: credentialType,
                title: title,
                issuedAt: issuedAt,
                expiresAt: expiresAt,
                storagePath: storagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PractitionerCredentialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PractitionerCredentialsTable,
      PractitionerCredential,
      $$PractitionerCredentialsTableFilterComposer,
      $$PractitionerCredentialsTableOrderingComposer,
      $$PractitionerCredentialsTableAnnotationComposer,
      $$PractitionerCredentialsTableCreateCompanionBuilder,
      $$PractitionerCredentialsTableUpdateCompanionBuilder,
      (
        PractitionerCredential,
        BaseReferences<
          _$AppDatabase,
          $PractitionerCredentialsTable,
          PractitionerCredential
        >,
      ),
      PractitionerCredential,
      PrefetchHooks Function()
    >;
typedef $$FinancialSummariesTableCreateCompanionBuilder =
    FinancialSummariesCompanion Function({
      required String id,
      required String facilityId,
      Value<String?> providerId,
      required String period,
      Value<double> revenue,
      Value<double> expenses,
      Value<double> outstanding,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FinancialSummariesTableUpdateCompanionBuilder =
    FinancialSummariesCompanion Function({
      Value<String> id,
      Value<String> facilityId,
      Value<String?> providerId,
      Value<String> period,
      Value<double> revenue,
      Value<double> expenses,
      Value<double> outstanding,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$FinancialSummariesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FinancialSummariesTable,
          FinancialSummary
        > {
  $$FinancialSummariesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FacilitiesTable _facilityIdTable(_$AppDatabase db) => db.facilities
      .createAlias('financial_summaries__facility_id__facilities__id');

  $$FacilitiesTableProcessedTableManager get facilityId {
    final $_column = $_itemColumn<String>('facility_id')!;

    final manager = $$FacilitiesTableTableManager(
      $_db,
      $_db.facilities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FinancialSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $FinancialSummariesTable> {
  $$FinancialSummariesTableFilterComposer({
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

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get revenue => $composableBuilder(
    column: $table.revenue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expenses => $composableBuilder(
    column: $table.expenses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get outstanding => $composableBuilder(
    column: $table.outstanding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FacilitiesTableFilterComposer get facilityId {
    final $$FacilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableFilterComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FinancialSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $FinancialSummariesTable> {
  $$FinancialSummariesTableOrderingComposer({
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

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get revenue => $composableBuilder(
    column: $table.revenue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expenses => $composableBuilder(
    column: $table.expenses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get outstanding => $composableBuilder(
    column: $table.outstanding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacilitiesTableOrderingComposer get facilityId {
    final $$FacilitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableOrderingComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FinancialSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinancialSummariesTable> {
  $$FinancialSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<double> get revenue =>
      $composableBuilder(column: $table.revenue, builder: (column) => column);

  GeneratedColumn<double> get expenses =>
      $composableBuilder(column: $table.expenses, builder: (column) => column);

  GeneratedColumn<double> get outstanding => $composableBuilder(
    column: $table.outstanding,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FacilitiesTableAnnotationComposer get facilityId {
    final $$FacilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FinancialSummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FinancialSummariesTable,
          FinancialSummary,
          $$FinancialSummariesTableFilterComposer,
          $$FinancialSummariesTableOrderingComposer,
          $$FinancialSummariesTableAnnotationComposer,
          $$FinancialSummariesTableCreateCompanionBuilder,
          $$FinancialSummariesTableUpdateCompanionBuilder,
          (FinancialSummary, $$FinancialSummariesTableReferences),
          FinancialSummary,
          PrefetchHooks Function({bool facilityId})
        > {
  $$FinancialSummariesTableTableManager(
    _$AppDatabase db,
    $FinancialSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialSummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialSummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialSummariesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<double> revenue = const Value.absent(),
                Value<double> expenses = const Value.absent(),
                Value<double> outstanding = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancialSummariesCompanion(
                id: id,
                facilityId: facilityId,
                providerId: providerId,
                period: period,
                revenue: revenue,
                expenses: expenses,
                outstanding: outstanding,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String facilityId,
                Value<String?> providerId = const Value.absent(),
                required String period,
                Value<double> revenue = const Value.absent(),
                Value<double> expenses = const Value.absent(),
                Value<double> outstanding = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FinancialSummariesCompanion.insert(
                id: id,
                facilityId: facilityId,
                providerId: providerId,
                period: period,
                revenue: revenue,
                expenses: expenses,
                outstanding: outstanding,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FinancialSummariesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({facilityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (facilityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.facilityId,
                                referencedTable:
                                    $$FinancialSummariesTableReferences
                                        ._facilityIdTable(db),
                                referencedColumn:
                                    $$FinancialSummariesTableReferences
                                        ._facilityIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FinancialSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FinancialSummariesTable,
      FinancialSummary,
      $$FinancialSummariesTableFilterComposer,
      $$FinancialSummariesTableOrderingComposer,
      $$FinancialSummariesTableAnnotationComposer,
      $$FinancialSummariesTableCreateCompanionBuilder,
      $$FinancialSummariesTableUpdateCompanionBuilder,
      (FinancialSummary, $$FinancialSummariesTableReferences),
      FinancialSummary,
      PrefetchHooks Function({bool facilityId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FacilitiesTableTableManager get facilities =>
      $$FacilitiesTableTableManager(_db, _db.facilities);
  $$FacilityMembershipsTableTableManager get facilityMemberships =>
      $$FacilityMembershipsTableTableManager(_db, _db.facilityMemberships);
  $$PractitionersTableTableManager get practitioners =>
      $$PractitionersTableTableManager(_db, _db.practitioners);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$PatientAllergiesTableTableManager get patientAllergies =>
      $$PatientAllergiesTableTableManager(_db, _db.patientAllergies);
  $$PatientConditionsTableTableManager get patientConditions =>
      $$PatientConditionsTableTableManager(_db, _db.patientConditions);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
  $$QueueEntriesTableTableManager get queueEntries =>
      $$QueueEntriesTableTableManager(_db, _db.queueEntries);
  $$ConsultationsTableTableManager get consultations =>
      $$ConsultationsTableTableManager(_db, _db.consultations);
  $$DiagnosesTableTableManager get diagnoses =>
      $$DiagnosesTableTableManager(_db, _db.diagnoses);
  $$VitalsTableTableManager get vitals =>
      $$VitalsTableTableManager(_db, _db.vitals);
  $$PrescriptionsTableTableManager get prescriptions =>
      $$PrescriptionsTableTableManager(_db, _db.prescriptions);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$FeatureFlagsTableTableManager get featureFlags =>
      $$FeatureFlagsTableTableManager(_db, _db.featureFlags);
  $$Icd11CodesTableTableManager get icd11Codes =>
      $$Icd11CodesTableTableManager(_db, _db.icd11Codes);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$EdlizRecommendationsTableTableManager get edlizRecommendations =>
      $$EdlizRecommendationsTableTableManager(_db, _db.edlizRecommendations);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$InsuranceClaimsTableTableManager get insuranceClaims =>
      $$InsuranceClaimsTableTableManager(_db, _db.insuranceClaims);
  $$ClinicalTasksTableTableManager get clinicalTasks =>
      $$ClinicalTasksTableTableManager(_db, _db.clinicalTasks);
  $$InternalMessagesTableTableManager get internalMessages =>
      $$InternalMessagesTableTableManager(_db, _db.internalMessages);
  $$PractitionerCredentialsTableTableManager get practitionerCredentials =>
      $$PractitionerCredentialsTableTableManager(
        _db,
        _db.practitionerCredentials,
      );
  $$FinancialSummariesTableTableManager get financialSummaries =>
      $$FinancialSummariesTableTableManager(_db, _db.financialSummaries);
}
