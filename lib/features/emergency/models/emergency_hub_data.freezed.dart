// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emergency_hub_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmergencyHubData {

 List<EmergencyService> get services; List<EmergencyFacility> get facilities; DateTime get cachedAt; bool get locationRequired;
/// Create a copy of EmergencyHubData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmergencyHubDataCopyWith<EmergencyHubData> get copyWith => _$EmergencyHubDataCopyWithImpl<EmergencyHubData>(this as EmergencyHubData, _$identity);

  /// Serializes this EmergencyHubData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmergencyHubData&&const DeepCollectionEquality().equals(other.services, services)&&const DeepCollectionEquality().equals(other.facilities, facilities)&&(identical(other.cachedAt, cachedAt) || other.cachedAt == cachedAt)&&(identical(other.locationRequired, locationRequired) || other.locationRequired == locationRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(services),const DeepCollectionEquality().hash(facilities),cachedAt,locationRequired);

@override
String toString() {
  return 'EmergencyHubData(services: $services, facilities: $facilities, cachedAt: $cachedAt, locationRequired: $locationRequired)';
}


}

/// @nodoc
abstract mixin class $EmergencyHubDataCopyWith<$Res>  {
  factory $EmergencyHubDataCopyWith(EmergencyHubData value, $Res Function(EmergencyHubData) _then) = _$EmergencyHubDataCopyWithImpl;
@useResult
$Res call({
 List<EmergencyService> services, List<EmergencyFacility> facilities, DateTime cachedAt, bool locationRequired
});




}
/// @nodoc
class _$EmergencyHubDataCopyWithImpl<$Res>
    implements $EmergencyHubDataCopyWith<$Res> {
  _$EmergencyHubDataCopyWithImpl(this._self, this._then);

  final EmergencyHubData _self;
  final $Res Function(EmergencyHubData) _then;

/// Create a copy of EmergencyHubData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? services = null,Object? facilities = null,Object? cachedAt = null,Object? locationRequired = null,}) {
  return _then(_self.copyWith(
services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<EmergencyService>,facilities: null == facilities ? _self.facilities : facilities // ignore: cast_nullable_to_non_nullable
as List<EmergencyFacility>,cachedAt: null == cachedAt ? _self.cachedAt : cachedAt // ignore: cast_nullable_to_non_nullable
as DateTime,locationRequired: null == locationRequired ? _self.locationRequired : locationRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EmergencyHubData].
extension EmergencyHubDataPatterns on EmergencyHubData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmergencyHubData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmergencyHubData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmergencyHubData value)  $default,){
final _that = this;
switch (_that) {
case _EmergencyHubData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmergencyHubData value)?  $default,){
final _that = this;
switch (_that) {
case _EmergencyHubData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EmergencyService> services,  List<EmergencyFacility> facilities,  DateTime cachedAt,  bool locationRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmergencyHubData() when $default != null:
return $default(_that.services,_that.facilities,_that.cachedAt,_that.locationRequired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EmergencyService> services,  List<EmergencyFacility> facilities,  DateTime cachedAt,  bool locationRequired)  $default,) {final _that = this;
switch (_that) {
case _EmergencyHubData():
return $default(_that.services,_that.facilities,_that.cachedAt,_that.locationRequired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EmergencyService> services,  List<EmergencyFacility> facilities,  DateTime cachedAt,  bool locationRequired)?  $default,) {final _that = this;
switch (_that) {
case _EmergencyHubData() when $default != null:
return $default(_that.services,_that.facilities,_that.cachedAt,_that.locationRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmergencyHubData implements EmergencyHubData {
  const _EmergencyHubData({required final  List<EmergencyService> services, required final  List<EmergencyFacility> facilities, required this.cachedAt, this.locationRequired = false}): _services = services,_facilities = facilities;
  factory _EmergencyHubData.fromJson(Map<String, dynamic> json) => _$EmergencyHubDataFromJson(json);

 final  List<EmergencyService> _services;
@override List<EmergencyService> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

 final  List<EmergencyFacility> _facilities;
@override List<EmergencyFacility> get facilities {
  if (_facilities is EqualUnmodifiableListView) return _facilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_facilities);
}

@override final  DateTime cachedAt;
@override@JsonKey() final  bool locationRequired;

/// Create a copy of EmergencyHubData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmergencyHubDataCopyWith<_EmergencyHubData> get copyWith => __$EmergencyHubDataCopyWithImpl<_EmergencyHubData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmergencyHubDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmergencyHubData&&const DeepCollectionEquality().equals(other._services, _services)&&const DeepCollectionEquality().equals(other._facilities, _facilities)&&(identical(other.cachedAt, cachedAt) || other.cachedAt == cachedAt)&&(identical(other.locationRequired, locationRequired) || other.locationRequired == locationRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_services),const DeepCollectionEquality().hash(_facilities),cachedAt,locationRequired);

@override
String toString() {
  return 'EmergencyHubData(services: $services, facilities: $facilities, cachedAt: $cachedAt, locationRequired: $locationRequired)';
}


}

/// @nodoc
abstract mixin class _$EmergencyHubDataCopyWith<$Res> implements $EmergencyHubDataCopyWith<$Res> {
  factory _$EmergencyHubDataCopyWith(_EmergencyHubData value, $Res Function(_EmergencyHubData) _then) = __$EmergencyHubDataCopyWithImpl;
@override @useResult
$Res call({
 List<EmergencyService> services, List<EmergencyFacility> facilities, DateTime cachedAt, bool locationRequired
});




}
/// @nodoc
class __$EmergencyHubDataCopyWithImpl<$Res>
    implements _$EmergencyHubDataCopyWith<$Res> {
  __$EmergencyHubDataCopyWithImpl(this._self, this._then);

  final _EmergencyHubData _self;
  final $Res Function(_EmergencyHubData) _then;

/// Create a copy of EmergencyHubData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? services = null,Object? facilities = null,Object? cachedAt = null,Object? locationRequired = null,}) {
  return _then(_EmergencyHubData(
services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<EmergencyService>,facilities: null == facilities ? _self._facilities : facilities // ignore: cast_nullable_to_non_nullable
as List<EmergencyFacility>,cachedAt: null == cachedAt ? _self.cachedAt : cachedAt // ignore: cast_nullable_to_non_nullable
as DateTime,locationRequired: null == locationRequired ? _self.locationRequired : locationRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
