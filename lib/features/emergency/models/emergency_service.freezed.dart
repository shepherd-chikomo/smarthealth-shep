// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emergency_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmergencyService {

 String get id; String get name; EmergencyServiceKind get kind; String get phone; double get nearestDistanceKm; String? get nearestProviderName; double? get nearestLatitude; double? get nearestLongitude;
/// Create a copy of EmergencyService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmergencyServiceCopyWith<EmergencyService> get copyWith => _$EmergencyServiceCopyWithImpl<EmergencyService>(this as EmergencyService, _$identity);

  /// Serializes this EmergencyService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmergencyService&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.nearestDistanceKm, nearestDistanceKm) || other.nearestDistanceKm == nearestDistanceKm)&&(identical(other.nearestProviderName, nearestProviderName) || other.nearestProviderName == nearestProviderName)&&(identical(other.nearestLatitude, nearestLatitude) || other.nearestLatitude == nearestLatitude)&&(identical(other.nearestLongitude, nearestLongitude) || other.nearestLongitude == nearestLongitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,kind,phone,nearestDistanceKm,nearestProviderName,nearestLatitude,nearestLongitude);

@override
String toString() {
  return 'EmergencyService(id: $id, name: $name, kind: $kind, phone: $phone, nearestDistanceKm: $nearestDistanceKm, nearestProviderName: $nearestProviderName, nearestLatitude: $nearestLatitude, nearestLongitude: $nearestLongitude)';
}


}

/// @nodoc
abstract mixin class $EmergencyServiceCopyWith<$Res>  {
  factory $EmergencyServiceCopyWith(EmergencyService value, $Res Function(EmergencyService) _then) = _$EmergencyServiceCopyWithImpl;
@useResult
$Res call({
 String id, String name, EmergencyServiceKind kind, String phone, double nearestDistanceKm, String? nearestProviderName, double? nearestLatitude, double? nearestLongitude
});




}
/// @nodoc
class _$EmergencyServiceCopyWithImpl<$Res>
    implements $EmergencyServiceCopyWith<$Res> {
  _$EmergencyServiceCopyWithImpl(this._self, this._then);

  final EmergencyService _self;
  final $Res Function(EmergencyService) _then;

/// Create a copy of EmergencyService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? phone = null,Object? nearestDistanceKm = null,Object? nearestProviderName = freezed,Object? nearestLatitude = freezed,Object? nearestLongitude = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as EmergencyServiceKind,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,nearestDistanceKm: null == nearestDistanceKm ? _self.nearestDistanceKm : nearestDistanceKm // ignore: cast_nullable_to_non_nullable
as double,nearestProviderName: freezed == nearestProviderName ? _self.nearestProviderName : nearestProviderName // ignore: cast_nullable_to_non_nullable
as String?,nearestLatitude: freezed == nearestLatitude ? _self.nearestLatitude : nearestLatitude // ignore: cast_nullable_to_non_nullable
as double?,nearestLongitude: freezed == nearestLongitude ? _self.nearestLongitude : nearestLongitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmergencyService].
extension EmergencyServicePatterns on EmergencyService {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmergencyService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmergencyService() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmergencyService value)  $default,){
final _that = this;
switch (_that) {
case _EmergencyService():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmergencyService value)?  $default,){
final _that = this;
switch (_that) {
case _EmergencyService() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  EmergencyServiceKind kind,  String phone,  double nearestDistanceKm,  String? nearestProviderName,  double? nearestLatitude,  double? nearestLongitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmergencyService() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.phone,_that.nearestDistanceKm,_that.nearestProviderName,_that.nearestLatitude,_that.nearestLongitude);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  EmergencyServiceKind kind,  String phone,  double nearestDistanceKm,  String? nearestProviderName,  double? nearestLatitude,  double? nearestLongitude)  $default,) {final _that = this;
switch (_that) {
case _EmergencyService():
return $default(_that.id,_that.name,_that.kind,_that.phone,_that.nearestDistanceKm,_that.nearestProviderName,_that.nearestLatitude,_that.nearestLongitude);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  EmergencyServiceKind kind,  String phone,  double nearestDistanceKm,  String? nearestProviderName,  double? nearestLatitude,  double? nearestLongitude)?  $default,) {final _that = this;
switch (_that) {
case _EmergencyService() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.phone,_that.nearestDistanceKm,_that.nearestProviderName,_that.nearestLatitude,_that.nearestLongitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmergencyService implements EmergencyService {
  const _EmergencyService({required this.id, required this.name, required this.kind, required this.phone, required this.nearestDistanceKm, this.nearestProviderName, this.nearestLatitude, this.nearestLongitude});
  factory _EmergencyService.fromJson(Map<String, dynamic> json) => _$EmergencyServiceFromJson(json);

@override final  String id;
@override final  String name;
@override final  EmergencyServiceKind kind;
@override final  String phone;
@override final  double nearestDistanceKm;
@override final  String? nearestProviderName;
@override final  double? nearestLatitude;
@override final  double? nearestLongitude;

/// Create a copy of EmergencyService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmergencyServiceCopyWith<_EmergencyService> get copyWith => __$EmergencyServiceCopyWithImpl<_EmergencyService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmergencyServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmergencyService&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.nearestDistanceKm, nearestDistanceKm) || other.nearestDistanceKm == nearestDistanceKm)&&(identical(other.nearestProviderName, nearestProviderName) || other.nearestProviderName == nearestProviderName)&&(identical(other.nearestLatitude, nearestLatitude) || other.nearestLatitude == nearestLatitude)&&(identical(other.nearestLongitude, nearestLongitude) || other.nearestLongitude == nearestLongitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,kind,phone,nearestDistanceKm,nearestProviderName,nearestLatitude,nearestLongitude);

@override
String toString() {
  return 'EmergencyService(id: $id, name: $name, kind: $kind, phone: $phone, nearestDistanceKm: $nearestDistanceKm, nearestProviderName: $nearestProviderName, nearestLatitude: $nearestLatitude, nearestLongitude: $nearestLongitude)';
}


}

/// @nodoc
abstract mixin class _$EmergencyServiceCopyWith<$Res> implements $EmergencyServiceCopyWith<$Res> {
  factory _$EmergencyServiceCopyWith(_EmergencyService value, $Res Function(_EmergencyService) _then) = __$EmergencyServiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, EmergencyServiceKind kind, String phone, double nearestDistanceKm, String? nearestProviderName, double? nearestLatitude, double? nearestLongitude
});




}
/// @nodoc
class __$EmergencyServiceCopyWithImpl<$Res>
    implements _$EmergencyServiceCopyWith<$Res> {
  __$EmergencyServiceCopyWithImpl(this._self, this._then);

  final _EmergencyService _self;
  final $Res Function(_EmergencyService) _then;

/// Create a copy of EmergencyService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? phone = null,Object? nearestDistanceKm = null,Object? nearestProviderName = freezed,Object? nearestLatitude = freezed,Object? nearestLongitude = freezed,}) {
  return _then(_EmergencyService(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as EmergencyServiceKind,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,nearestDistanceKm: null == nearestDistanceKm ? _self.nearestDistanceKm : nearestDistanceKm // ignore: cast_nullable_to_non_nullable
as double,nearestProviderName: freezed == nearestProviderName ? _self.nearestProviderName : nearestProviderName // ignore: cast_nullable_to_non_nullable
as String?,nearestLatitude: freezed == nearestLatitude ? _self.nearestLatitude : nearestLatitude // ignore: cast_nullable_to_non_nullable
as double?,nearestLongitude: freezed == nearestLongitude ? _self.nearestLongitude : nearestLongitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
