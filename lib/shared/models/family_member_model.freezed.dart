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

 String get id; String get name; String get relationship; String? get dateOfBirth; FamilyGender? get gender; List<String> get medicalConditions; String? get allergies; bool get isPrimaryAccountHolder;@JsonKey(fromJson: _metadataFromJson, toJson: _metadataToJson) EmergencyMedicalMetadata? get metadata; DateTime? get updatedAt;
/// Create a copy of FamilyMemberModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyMemberModelCopyWith<FamilyMemberModel> get copyWith => _$FamilyMemberModelCopyWithImpl<FamilyMemberModel>(this as FamilyMemberModel, _$identity);

  /// Serializes this FamilyMemberModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyMemberModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.relationship, relationship) || other.relationship == relationship)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other.medicalConditions, medicalConditions)&&(identical(other.allergies, allergies) || other.allergies == allergies)&&(identical(other.isPrimaryAccountHolder, isPrimaryAccountHolder) || other.isPrimaryAccountHolder == isPrimaryAccountHolder)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,relationship,dateOfBirth,gender,const DeepCollectionEquality().hash(medicalConditions),allergies,isPrimaryAccountHolder,metadata,updatedAt);

@override
String toString() {
  return 'FamilyMemberModel(id: $id, name: $name, relationship: $relationship, dateOfBirth: $dateOfBirth, gender: $gender, medicalConditions: $medicalConditions, allergies: $allergies, isPrimaryAccountHolder: $isPrimaryAccountHolder, metadata: $metadata, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FamilyMemberModelCopyWith<$Res>  {
  factory $FamilyMemberModelCopyWith(FamilyMemberModel value, $Res Function(FamilyMemberModel) _then) = _$FamilyMemberModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String relationship, String? dateOfBirth, FamilyGender? gender, List<String> medicalConditions, String? allergies, bool isPrimaryAccountHolder,@JsonKey(fromJson: _metadataFromJson, toJson: _metadataToJson) EmergencyMedicalMetadata? metadata, DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? relationship = null,Object? dateOfBirth = freezed,Object? gender = freezed,Object? medicalConditions = null,Object? allergies = freezed,Object? isPrimaryAccountHolder = null,Object? metadata = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,relationship: null == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as FamilyGender?,medicalConditions: null == medicalConditions ? _self.medicalConditions : medicalConditions // ignore: cast_nullable_to_non_nullable
as List<String>,allergies: freezed == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as String?,isPrimaryAccountHolder: null == isPrimaryAccountHolder ? _self.isPrimaryAccountHolder : isPrimaryAccountHolder // ignore: cast_nullable_to_non_nullable
as bool,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as EmergencyMedicalMetadata?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String relationship,  String? dateOfBirth,  FamilyGender? gender,  List<String> medicalConditions,  String? allergies,  bool isPrimaryAccountHolder, @JsonKey(fromJson: _metadataFromJson, toJson: _metadataToJson)  EmergencyMedicalMetadata? metadata,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyMemberModel() when $default != null:
return $default(_that.id,_that.name,_that.relationship,_that.dateOfBirth,_that.gender,_that.medicalConditions,_that.allergies,_that.isPrimaryAccountHolder,_that.metadata,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String relationship,  String? dateOfBirth,  FamilyGender? gender,  List<String> medicalConditions,  String? allergies,  bool isPrimaryAccountHolder, @JsonKey(fromJson: _metadataFromJson, toJson: _metadataToJson)  EmergencyMedicalMetadata? metadata,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyMemberModel():
return $default(_that.id,_that.name,_that.relationship,_that.dateOfBirth,_that.gender,_that.medicalConditions,_that.allergies,_that.isPrimaryAccountHolder,_that.metadata,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String relationship,  String? dateOfBirth,  FamilyGender? gender,  List<String> medicalConditions,  String? allergies,  bool isPrimaryAccountHolder, @JsonKey(fromJson: _metadataFromJson, toJson: _metadataToJson)  EmergencyMedicalMetadata? metadata,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyMemberModel() when $default != null:
return $default(_that.id,_that.name,_that.relationship,_that.dateOfBirth,_that.gender,_that.medicalConditions,_that.allergies,_that.isPrimaryAccountHolder,_that.metadata,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyMemberModel extends FamilyMemberModel {
  const _FamilyMemberModel({required this.id, required this.name, required this.relationship, this.dateOfBirth, this.gender, final  List<String> medicalConditions = const [], this.allergies, this.isPrimaryAccountHolder = false, @JsonKey(fromJson: _metadataFromJson, toJson: _metadataToJson) this.metadata, this.updatedAt}): _medicalConditions = medicalConditions,super._();
  factory _FamilyMemberModel.fromJson(Map<String, dynamic> json) => _$FamilyMemberModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String relationship;
@override final  String? dateOfBirth;
@override final  FamilyGender? gender;
 final  List<String> _medicalConditions;
@override@JsonKey() List<String> get medicalConditions {
  if (_medicalConditions is EqualUnmodifiableListView) return _medicalConditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_medicalConditions);
}

@override final  String? allergies;
@override@JsonKey() final  bool isPrimaryAccountHolder;
@override@JsonKey(fromJson: _metadataFromJson, toJson: _metadataToJson) final  EmergencyMedicalMetadata? metadata;
@override final  DateTime? updatedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyMemberModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.relationship, relationship) || other.relationship == relationship)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other._medicalConditions, _medicalConditions)&&(identical(other.allergies, allergies) || other.allergies == allergies)&&(identical(other.isPrimaryAccountHolder, isPrimaryAccountHolder) || other.isPrimaryAccountHolder == isPrimaryAccountHolder)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,relationship,dateOfBirth,gender,const DeepCollectionEquality().hash(_medicalConditions),allergies,isPrimaryAccountHolder,metadata,updatedAt);

@override
String toString() {
  return 'FamilyMemberModel(id: $id, name: $name, relationship: $relationship, dateOfBirth: $dateOfBirth, gender: $gender, medicalConditions: $medicalConditions, allergies: $allergies, isPrimaryAccountHolder: $isPrimaryAccountHolder, metadata: $metadata, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyMemberModelCopyWith<$Res> implements $FamilyMemberModelCopyWith<$Res> {
  factory _$FamilyMemberModelCopyWith(_FamilyMemberModel value, $Res Function(_FamilyMemberModel) _then) = __$FamilyMemberModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String relationship, String? dateOfBirth, FamilyGender? gender, List<String> medicalConditions, String? allergies, bool isPrimaryAccountHolder,@JsonKey(fromJson: _metadataFromJson, toJson: _metadataToJson) EmergencyMedicalMetadata? metadata, DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? relationship = null,Object? dateOfBirth = freezed,Object? gender = freezed,Object? medicalConditions = null,Object? allergies = freezed,Object? isPrimaryAccountHolder = null,Object? metadata = freezed,Object? updatedAt = freezed,}) {
  return _then(_FamilyMemberModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,relationship: null == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as FamilyGender?,medicalConditions: null == medicalConditions ? _self._medicalConditions : medicalConditions // ignore: cast_nullable_to_non_nullable
as List<String>,allergies: freezed == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as String?,isPrimaryAccountHolder: null == isPrimaryAccountHolder ? _self.isPrimaryAccountHolder : isPrimaryAccountHolder // ignore: cast_nullable_to_non_nullable
as bool,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as EmergencyMedicalMetadata?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
