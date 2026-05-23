// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FamilyMemberModel {

 String get id; String get name; String get relationship; String? get dateOfBirth;
/// Create a copy of FamilyMemberModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyMemberModelCopyWith<FamilyMemberModel> get copyWith => _$FamilyMemberModelCopyWithImpl<FamilyMemberModel>(this as FamilyMemberModel, _$identity);

  /// Serializes this FamilyMemberModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyMemberModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.relationship, relationship) || other.relationship == relationship)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,relationship,dateOfBirth);

@override
String toString() {
  return 'FamilyMemberModel(id: $id, name: $name, relationship: $relationship, dateOfBirth: $dateOfBirth)';
}


}

/// @nodoc
abstract mixin class $FamilyMemberModelCopyWith<$Res>  {
  factory $FamilyMemberModelCopyWith(FamilyMemberModel value, $Res Function(FamilyMemberModel) _then) = _$FamilyMemberModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String relationship, String? dateOfBirth
});




}
/// @nodoc
class _$FamilyMemberModelCopyWithImpl<$Res>
    implements $FamilyMemberModelCopyWith<$Res> {
  _$FamilyMemberModelCopyWithImpl(this._self, this._then);

  final FamilyMemberModel _self;
  final $Res Function(FamilyMemberModel) _then;

/// Create a copy of FamilyMemberModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? relationship = null,Object? dateOfBirth = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,relationship: null == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyMemberModel].
extension FamilyMemberModelPatterns on FamilyMemberModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyMemberModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyMemberModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyMemberModel value)  $default,){
final _that = this;
switch (_that) {
case _FamilyMemberModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyMemberModel value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyMemberModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String relationship,  String? dateOfBirth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyMemberModel() when $default != null:
return $default(_that.id,_that.name,_that.relationship,_that.dateOfBirth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String relationship,  String? dateOfBirth)  $default,) {final _that = this;
switch (_that) {
case _FamilyMemberModel():
return $default(_that.id,_that.name,_that.relationship,_that.dateOfBirth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String relationship,  String? dateOfBirth)?  $default,) {final _that = this;
switch (_that) {
case _FamilyMemberModel() when $default != null:
return $default(_that.id,_that.name,_that.relationship,_that.dateOfBirth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyMemberModel implements FamilyMemberModel {
  const _FamilyMemberModel({required this.id, required this.name, required this.relationship, this.dateOfBirth});
  factory _FamilyMemberModel.fromJson(Map<String, dynamic> json) => _$FamilyMemberModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String relationship;
@override final  String? dateOfBirth;

/// Create a copy of FamilyMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyMemberModelCopyWith<_FamilyMemberModel> get copyWith => __$FamilyMemberModelCopyWithImpl<_FamilyMemberModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyMemberModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyMemberModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.relationship, relationship) || other.relationship == relationship)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,relationship,dateOfBirth);

@override
String toString() {
  return 'FamilyMemberModel(id: $id, name: $name, relationship: $relationship, dateOfBirth: $dateOfBirth)';
}


}

/// @nodoc
abstract mixin class _$FamilyMemberModelCopyWith<$Res> implements $FamilyMemberModelCopyWith<$Res> {
  factory _$FamilyMemberModelCopyWith(_FamilyMemberModel value, $Res Function(_FamilyMemberModel) _then) = __$FamilyMemberModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String relationship, String? dateOfBirth
});




}
/// @nodoc
class __$FamilyMemberModelCopyWithImpl<$Res>
    implements _$FamilyMemberModelCopyWith<$Res> {
  __$FamilyMemberModelCopyWithImpl(this._self, this._then);

  final _FamilyMemberModel _self;
  final $Res Function(_FamilyMemberModel) _then;

/// Create a copy of FamilyMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? relationship = null,Object? dateOfBirth = freezed,}) {
  return _then(_FamilyMemberModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,relationship: null == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
