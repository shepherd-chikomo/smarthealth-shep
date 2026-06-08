// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emergency_facility.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmergencyFacility {

 String get id; String get name; String get type; double get distanceKm; String get phone; double? get latitude; double? get longitude; bool get is24Hours; EmergencyFacilitySource? get source; String? get referralLabel; bool get pendingVerification;
/// Create a copy of EmergencyFacility
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmergencyFacilityCopyWith<EmergencyFacility> get copyWith => _$EmergencyFacilityCopyWithImpl<EmergencyFacility>(this as EmergencyFacility, _$identity);

  /// Serializes this EmergencyFacility to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmergencyFacility&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.is24Hours, is24Hours) || other.is24Hours == is24Hours)&&(identical(other.source, source) || other.source == source)&&(identical(other.referralLabel, referralLabel) || other.referralLabel == referralLabel)&&(identical(other.pendingVerification, pendingVerification) || other.pendingVerification == pendingVerification));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,distanceKm,phone,latitude,longitude,is24Hours,source,referralLabel,pendingVerification);

@override
String toString() {
  return 'EmergencyFacility(id: $id, name: $name, type: $type, distanceKm: $distanceKm, phone: $phone, latitude: $latitude, longitude: $longitude, is24Hours: $is24Hours, source: $source, referralLabel: $referralLabel, pendingVerification: $pendingVerification)';
}


}

/// @nodoc
abstract mixin class $EmergencyFacilityCopyWith<$Res>  {
  factory $EmergencyFacilityCopyWith(EmergencyFacility value, $Res Function(EmergencyFacility) _then) = _$EmergencyFacilityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, double distanceKm, String phone, double? latitude, double? longitude, bool is24Hours, EmergencyFacilitySource? source, String? referralLabel, bool pendingVerification
});




}
/// @nodoc
class _$EmergencyFacilityCopyWithImpl<$Res>
    implements $EmergencyFacilityCopyWith<$Res> {
  _$EmergencyFacilityCopyWithImpl(this._self, this._then);

  final EmergencyFacility _self;
  final $Res Function(EmergencyFacility) _then;

/// Create a copy of EmergencyFacility
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? distanceKm = null,Object? phone = null,Object? latitude = freezed,Object? longitude = freezed,Object? is24Hours = null,Object? source = freezed,Object? referralLabel = freezed,Object? pendingVerification = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,is24Hours: null == is24Hours ? _self.is24Hours : is24Hours // ignore: cast_nullable_to_non_nullable
as bool,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as EmergencyFacilitySource?,referralLabel: freezed == referralLabel ? _self.referralLabel : referralLabel // ignore: cast_nullable_to_non_nullable
as String?,pendingVerification: null == pendingVerification ? _self.pendingVerification : pendingVerification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EmergencyFacility].
extension EmergencyFacilityPatterns on EmergencyFacility {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmergencyFacility value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmergencyFacility() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmergencyFacility value)  $default,){
final _that = this;
switch (_that) {
case _EmergencyFacility():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmergencyFacility value)?  $default,){
final _that = this;
switch (_that) {
case _EmergencyFacility() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  double distanceKm,  String phone,  double? latitude,  double? longitude,  bool is24Hours,  EmergencyFacilitySource? source,  String? referralLabel,  bool pendingVerification)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmergencyFacility() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.distanceKm,_that.phone,_that.latitude,_that.longitude,_that.is24Hours,_that.source,_that.referralLabel,_that.pendingVerification);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  double distanceKm,  String phone,  double? latitude,  double? longitude,  bool is24Hours,  EmergencyFacilitySource? source,  String? referralLabel,  bool pendingVerification)  $default,) {final _that = this;
switch (_that) {
case _EmergencyFacility():
return $default(_that.id,_that.name,_that.type,_that.distanceKm,_that.phone,_that.latitude,_that.longitude,_that.is24Hours,_that.source,_that.referralLabel,_that.pendingVerification);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  double distanceKm,  String phone,  double? latitude,  double? longitude,  bool is24Hours,  EmergencyFacilitySource? source,  String? referralLabel,  bool pendingVerification)?  $default,) {final _that = this;
switch (_that) {
case _EmergencyFacility() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.distanceKm,_that.phone,_that.latitude,_that.longitude,_that.is24Hours,_that.source,_that.referralLabel,_that.pendingVerification);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmergencyFacility implements EmergencyFacility {
  const _EmergencyFacility({required this.id, required this.name, required this.type, required this.distanceKm, required this.phone, this.latitude, this.longitude, this.is24Hours = true, this.source, this.referralLabel, this.pendingVerification = false});
  factory _EmergencyFacility.fromJson(Map<String, dynamic> json) => _$EmergencyFacilityFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override final  double distanceKm;
@override final  String phone;
@override final  double? latitude;
@override final  double? longitude;
@override@JsonKey() final  bool is24Hours;
@override final  EmergencyFacilitySource? source;
@override final  String? referralLabel;
@override@JsonKey() final  bool pendingVerification;

/// Create a copy of EmergencyFacility
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmergencyFacilityCopyWith<_EmergencyFacility> get copyWith => __$EmergencyFacilityCopyWithImpl<_EmergencyFacility>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmergencyFacilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmergencyFacility&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.is24Hours, is24Hours) || other.is24Hours == is24Hours)&&(identical(other.source, source) || other.source == source)&&(identical(other.referralLabel, referralLabel) || other.referralLabel == referralLabel)&&(identical(other.pendingVerification, pendingVerification) || other.pendingVerification == pendingVerification));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,distanceKm,phone,latitude,longitude,is24Hours,source,referralLabel,pendingVerification);

@override
String toString() {
  return 'EmergencyFacility(id: $id, name: $name, type: $type, distanceKm: $distanceKm, phone: $phone, latitude: $latitude, longitude: $longitude, is24Hours: $is24Hours, source: $source, referralLabel: $referralLabel, pendingVerification: $pendingVerification)';
}


}

/// @nodoc
abstract mixin class _$EmergencyFacilityCopyWith<$Res> implements $EmergencyFacilityCopyWith<$Res> {
  factory _$EmergencyFacilityCopyWith(_EmergencyFacility value, $Res Function(_EmergencyFacility) _then) = __$EmergencyFacilityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, double distanceKm, String phone, double? latitude, double? longitude, bool is24Hours, EmergencyFacilitySource? source, String? referralLabel, bool pendingVerification
});




}
/// @nodoc
class __$EmergencyFacilityCopyWithImpl<$Res>
    implements _$EmergencyFacilityCopyWith<$Res> {
  __$EmergencyFacilityCopyWithImpl(this._self, this._then);

  final _EmergencyFacility _self;
  final $Res Function(_EmergencyFacility) _then;

/// Create a copy of EmergencyFacility
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? distanceKm = null,Object? phone = null,Object? latitude = freezed,Object? longitude = freezed,Object? is24Hours = null,Object? source = freezed,Object? referralLabel = freezed,Object? pendingVerification = null,}) {
  return _then(_EmergencyFacility(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,is24Hours: null == is24Hours ? _self.is24Hours : is24Hours // ignore: cast_nullable_to_non_nullable
as bool,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as EmergencyFacilitySource?,referralLabel: freezed == referralLabel ? _self.referralLabel : referralLabel // ignore: cast_nullable_to_non_nullable
as String?,pendingVerification: null == pendingVerification ? _self.pendingVerification : pendingVerification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
