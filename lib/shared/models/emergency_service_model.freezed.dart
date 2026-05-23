// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emergency_service_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmergencyServiceModel {

 String get id; String get name; String get phone; String? get whatsapp; bool get is24Hours;
/// Create a copy of EmergencyServiceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmergencyServiceModelCopyWith<EmergencyServiceModel> get copyWith => _$EmergencyServiceModelCopyWithImpl<EmergencyServiceModel>(this as EmergencyServiceModel, _$identity);

  /// Serializes this EmergencyServiceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmergencyServiceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp)&&(identical(other.is24Hours, is24Hours) || other.is24Hours == is24Hours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,whatsapp,is24Hours);

@override
String toString() {
  return 'EmergencyServiceModel(id: $id, name: $name, phone: $phone, whatsapp: $whatsapp, is24Hours: $is24Hours)';
}


}

/// @nodoc
abstract mixin class $EmergencyServiceModelCopyWith<$Res>  {
  factory $EmergencyServiceModelCopyWith(EmergencyServiceModel value, $Res Function(EmergencyServiceModel) _then) = _$EmergencyServiceModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String phone, String? whatsapp, bool is24Hours
});




}
/// @nodoc
class _$EmergencyServiceModelCopyWithImpl<$Res>
    implements $EmergencyServiceModelCopyWith<$Res> {
  _$EmergencyServiceModelCopyWithImpl(this._self, this._then);

  final EmergencyServiceModel _self;
  final $Res Function(EmergencyServiceModel) _then;

/// Create a copy of EmergencyServiceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? whatsapp = freezed,Object? is24Hours = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,is24Hours: null == is24Hours ? _self.is24Hours : is24Hours // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EmergencyServiceModel].
extension EmergencyServiceModelPatterns on EmergencyServiceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmergencyServiceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmergencyServiceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmergencyServiceModel value)  $default,){
final _that = this;
switch (_that) {
case _EmergencyServiceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmergencyServiceModel value)?  $default,){
final _that = this;
switch (_that) {
case _EmergencyServiceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String phone,  String? whatsapp,  bool is24Hours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmergencyServiceModel() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.whatsapp,_that.is24Hours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String phone,  String? whatsapp,  bool is24Hours)  $default,) {final _that = this;
switch (_that) {
case _EmergencyServiceModel():
return $default(_that.id,_that.name,_that.phone,_that.whatsapp,_that.is24Hours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String phone,  String? whatsapp,  bool is24Hours)?  $default,) {final _that = this;
switch (_that) {
case _EmergencyServiceModel() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.whatsapp,_that.is24Hours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmergencyServiceModel implements EmergencyServiceModel {
  const _EmergencyServiceModel({required this.id, required this.name, required this.phone, this.whatsapp, this.is24Hours = false});
  factory _EmergencyServiceModel.fromJson(Map<String, dynamic> json) => _$EmergencyServiceModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String phone;
@override final  String? whatsapp;
@override@JsonKey() final  bool is24Hours;

/// Create a copy of EmergencyServiceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmergencyServiceModelCopyWith<_EmergencyServiceModel> get copyWith => __$EmergencyServiceModelCopyWithImpl<_EmergencyServiceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmergencyServiceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmergencyServiceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp)&&(identical(other.is24Hours, is24Hours) || other.is24Hours == is24Hours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,whatsapp,is24Hours);

@override
String toString() {
  return 'EmergencyServiceModel(id: $id, name: $name, phone: $phone, whatsapp: $whatsapp, is24Hours: $is24Hours)';
}


}

/// @nodoc
abstract mixin class _$EmergencyServiceModelCopyWith<$Res> implements $EmergencyServiceModelCopyWith<$Res> {
  factory _$EmergencyServiceModelCopyWith(_EmergencyServiceModel value, $Res Function(_EmergencyServiceModel) _then) = __$EmergencyServiceModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String phone, String? whatsapp, bool is24Hours
});




}
/// @nodoc
class __$EmergencyServiceModelCopyWithImpl<$Res>
    implements _$EmergencyServiceModelCopyWith<$Res> {
  __$EmergencyServiceModelCopyWithImpl(this._self, this._then);

  final _EmergencyServiceModel _self;
  final $Res Function(_EmergencyServiceModel) _then;

/// Create a copy of EmergencyServiceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? whatsapp = freezed,Object? is24Hours = null,}) {
  return _then(_EmergencyServiceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,is24Hours: null == is24Hours ? _self.is24Hours : is24Hours // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
