// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FacilityModel {

 String get id; String get name; String get slug; String get facilityType; List<String> get facilityTypes; String? get description; String? get addressLine1; String get city; String get province; String? get phone; String? get whatsappPhone; String? get email; String? get website; double? get latitude; double? get longitude; double? get distanceKm; bool get isVerified; String? get logoPath; List<String> get acceptedMedicalAidSchemeKeys; bool get acceptsYourMedicalAid;
/// Create a copy of FacilityModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityModelCopyWith<FacilityModel> get copyWith => _$FacilityModelCopyWithImpl<FacilityModel>(this as FacilityModel, _$identity);

  /// Serializes this FacilityModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilityModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.facilityType, facilityType) || other.facilityType == facilityType)&&const DeepCollectionEquality().equals(other.facilityTypes, facilityTypes)&&(identical(other.description, description) || other.description == description)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.city, city) || other.city == city)&&(identical(other.province, province) || other.province == province)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.whatsappPhone, whatsappPhone) || other.whatsappPhone == whatsappPhone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&const DeepCollectionEquality().equals(other.acceptedMedicalAidSchemeKeys, acceptedMedicalAidSchemeKeys)&&(identical(other.acceptsYourMedicalAid, acceptsYourMedicalAid) || other.acceptsYourMedicalAid == acceptsYourMedicalAid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,facilityType,const DeepCollectionEquality().hash(facilityTypes),description,addressLine1,city,province,phone,whatsappPhone,email,website,latitude,longitude,distanceKm,isVerified,logoPath,const DeepCollectionEquality().hash(acceptedMedicalAidSchemeKeys),acceptsYourMedicalAid]);

@override
String toString() {
  return 'FacilityModel(id: $id, name: $name, slug: $slug, facilityType: $facilityType, facilityTypes: $facilityTypes, description: $description, addressLine1: $addressLine1, city: $city, province: $province, phone: $phone, whatsappPhone: $whatsappPhone, email: $email, website: $website, latitude: $latitude, longitude: $longitude, distanceKm: $distanceKm, isVerified: $isVerified, logoPath: $logoPath, acceptedMedicalAidSchemeKeys: $acceptedMedicalAidSchemeKeys, acceptsYourMedicalAid: $acceptsYourMedicalAid)';
}


}

/// @nodoc
abstract mixin class $FacilityModelCopyWith<$Res>  {
  factory $FacilityModelCopyWith(FacilityModel value, $Res Function(FacilityModel) _then) = _$FacilityModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug, String facilityType, List<String> facilityTypes, String? description, String? addressLine1, String city, String province, String? phone, String? whatsappPhone, String? email, String? website, double? latitude, double? longitude, double? distanceKm, bool isVerified, String? logoPath, List<String> acceptedMedicalAidSchemeKeys, bool acceptsYourMedicalAid
});




}
/// @nodoc
class _$FacilityModelCopyWithImpl<$Res>
    implements $FacilityModelCopyWith<$Res> {
  _$FacilityModelCopyWithImpl(this._self, this._then);

  final FacilityModel _self;
  final $Res Function(FacilityModel) _then;

/// Create a copy of FacilityModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? facilityType = null,Object? facilityTypes = null,Object? description = freezed,Object? addressLine1 = freezed,Object? city = null,Object? province = null,Object? phone = freezed,Object? whatsappPhone = freezed,Object? email = freezed,Object? website = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? distanceKm = freezed,Object? isVerified = null,Object? logoPath = freezed,Object? acceptedMedicalAidSchemeKeys = null,Object? acceptsYourMedicalAid = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,facilityType: null == facilityType ? _self.facilityType : facilityType // ignore: cast_nullable_to_non_nullable
as String,facilityTypes: null == facilityTypes ? _self.facilityTypes : facilityTypes // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: freezed == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String?,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,province: null == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,whatsappPhone: freezed == whatsappPhone ? _self.whatsappPhone : whatsappPhone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,acceptedMedicalAidSchemeKeys: null == acceptedMedicalAidSchemeKeys ? _self.acceptedMedicalAidSchemeKeys : acceptedMedicalAidSchemeKeys // ignore: cast_nullable_to_non_nullable
as List<String>,acceptsYourMedicalAid: null == acceptsYourMedicalAid ? _self.acceptsYourMedicalAid : acceptsYourMedicalAid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FacilityModel].
extension FacilityModelPatterns on FacilityModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilityModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilityModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilityModel value)  $default,){
final _that = this;
switch (_that) {
case _FacilityModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilityModel value)?  $default,){
final _that = this;
switch (_that) {
case _FacilityModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String facilityType,  List<String> facilityTypes,  String? description,  String? addressLine1,  String city,  String province,  String? phone,  String? whatsappPhone,  String? email,  String? website,  double? latitude,  double? longitude,  double? distanceKm,  bool isVerified,  String? logoPath,  List<String> acceptedMedicalAidSchemeKeys,  bool acceptsYourMedicalAid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilityModel() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.facilityType,_that.facilityTypes,_that.description,_that.addressLine1,_that.city,_that.province,_that.phone,_that.whatsappPhone,_that.email,_that.website,_that.latitude,_that.longitude,_that.distanceKm,_that.isVerified,_that.logoPath,_that.acceptedMedicalAidSchemeKeys,_that.acceptsYourMedicalAid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String facilityType,  List<String> facilityTypes,  String? description,  String? addressLine1,  String city,  String province,  String? phone,  String? whatsappPhone,  String? email,  String? website,  double? latitude,  double? longitude,  double? distanceKm,  bool isVerified,  String? logoPath,  List<String> acceptedMedicalAidSchemeKeys,  bool acceptsYourMedicalAid)  $default,) {final _that = this;
switch (_that) {
case _FacilityModel():
return $default(_that.id,_that.name,_that.slug,_that.facilityType,_that.facilityTypes,_that.description,_that.addressLine1,_that.city,_that.province,_that.phone,_that.whatsappPhone,_that.email,_that.website,_that.latitude,_that.longitude,_that.distanceKm,_that.isVerified,_that.logoPath,_that.acceptedMedicalAidSchemeKeys,_that.acceptsYourMedicalAid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug,  String facilityType,  List<String> facilityTypes,  String? description,  String? addressLine1,  String city,  String province,  String? phone,  String? whatsappPhone,  String? email,  String? website,  double? latitude,  double? longitude,  double? distanceKm,  bool isVerified,  String? logoPath,  List<String> acceptedMedicalAidSchemeKeys,  bool acceptsYourMedicalAid)?  $default,) {final _that = this;
switch (_that) {
case _FacilityModel() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.facilityType,_that.facilityTypes,_that.description,_that.addressLine1,_that.city,_that.province,_that.phone,_that.whatsappPhone,_that.email,_that.website,_that.latitude,_that.longitude,_that.distanceKm,_that.isVerified,_that.logoPath,_that.acceptedMedicalAidSchemeKeys,_that.acceptsYourMedicalAid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FacilityModel extends FacilityModel {
  const _FacilityModel({required this.id, required this.name, required this.slug, required this.facilityType, final  List<String> facilityTypes = const [], this.description, this.addressLine1, required this.city, required this.province, this.phone, this.whatsappPhone, this.email, this.website, this.latitude, this.longitude, this.distanceKm, this.isVerified = false, this.logoPath, final  List<String> acceptedMedicalAidSchemeKeys = const [], this.acceptsYourMedicalAid = false}): _facilityTypes = facilityTypes,_acceptedMedicalAidSchemeKeys = acceptedMedicalAidSchemeKeys,super._();
  factory _FacilityModel.fromJson(Map<String, dynamic> json) => _$FacilityModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override final  String facilityType;
 final  List<String> _facilityTypes;
@override@JsonKey() List<String> get facilityTypes {
  if (_facilityTypes is EqualUnmodifiableListView) return _facilityTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_facilityTypes);
}

@override final  String? description;
@override final  String? addressLine1;
@override final  String city;
@override final  String province;
@override final  String? phone;
@override final  String? whatsappPhone;
@override final  String? email;
@override final  String? website;
@override final  double? latitude;
@override final  double? longitude;
@override final  double? distanceKm;
@override@JsonKey() final  bool isVerified;
@override final  String? logoPath;
 final  List<String> _acceptedMedicalAidSchemeKeys;
@override@JsonKey() List<String> get acceptedMedicalAidSchemeKeys {
  if (_acceptedMedicalAidSchemeKeys is EqualUnmodifiableListView) return _acceptedMedicalAidSchemeKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_acceptedMedicalAidSchemeKeys);
}

@override@JsonKey() final  bool acceptsYourMedicalAid;

/// Create a copy of FacilityModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityModelCopyWith<_FacilityModel> get copyWith => __$FacilityModelCopyWithImpl<_FacilityModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FacilityModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilityModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.facilityType, facilityType) || other.facilityType == facilityType)&&const DeepCollectionEquality().equals(other._facilityTypes, _facilityTypes)&&(identical(other.description, description) || other.description == description)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.city, city) || other.city == city)&&(identical(other.province, province) || other.province == province)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.whatsappPhone, whatsappPhone) || other.whatsappPhone == whatsappPhone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&const DeepCollectionEquality().equals(other._acceptedMedicalAidSchemeKeys, _acceptedMedicalAidSchemeKeys)&&(identical(other.acceptsYourMedicalAid, acceptsYourMedicalAid) || other.acceptsYourMedicalAid == acceptsYourMedicalAid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,facilityType,const DeepCollectionEquality().hash(_facilityTypes),description,addressLine1,city,province,phone,whatsappPhone,email,website,latitude,longitude,distanceKm,isVerified,logoPath,const DeepCollectionEquality().hash(_acceptedMedicalAidSchemeKeys),acceptsYourMedicalAid]);

@override
String toString() {
  return 'FacilityModel(id: $id, name: $name, slug: $slug, facilityType: $facilityType, facilityTypes: $facilityTypes, description: $description, addressLine1: $addressLine1, city: $city, province: $province, phone: $phone, whatsappPhone: $whatsappPhone, email: $email, website: $website, latitude: $latitude, longitude: $longitude, distanceKm: $distanceKm, isVerified: $isVerified, logoPath: $logoPath, acceptedMedicalAidSchemeKeys: $acceptedMedicalAidSchemeKeys, acceptsYourMedicalAid: $acceptsYourMedicalAid)';
}


}

/// @nodoc
abstract mixin class _$FacilityModelCopyWith<$Res> implements $FacilityModelCopyWith<$Res> {
  factory _$FacilityModelCopyWith(_FacilityModel value, $Res Function(_FacilityModel) _then) = __$FacilityModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug, String facilityType, List<String> facilityTypes, String? description, String? addressLine1, String city, String province, String? phone, String? whatsappPhone, String? email, String? website, double? latitude, double? longitude, double? distanceKm, bool isVerified, String? logoPath, List<String> acceptedMedicalAidSchemeKeys, bool acceptsYourMedicalAid
});




}
/// @nodoc
class __$FacilityModelCopyWithImpl<$Res>
    implements _$FacilityModelCopyWith<$Res> {
  __$FacilityModelCopyWithImpl(this._self, this._then);

  final _FacilityModel _self;
  final $Res Function(_FacilityModel) _then;

/// Create a copy of FacilityModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? facilityType = null,Object? facilityTypes = null,Object? description = freezed,Object? addressLine1 = freezed,Object? city = null,Object? province = null,Object? phone = freezed,Object? whatsappPhone = freezed,Object? email = freezed,Object? website = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? distanceKm = freezed,Object? isVerified = null,Object? logoPath = freezed,Object? acceptedMedicalAidSchemeKeys = null,Object? acceptsYourMedicalAid = null,}) {
  return _then(_FacilityModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,facilityType: null == facilityType ? _self.facilityType : facilityType // ignore: cast_nullable_to_non_nullable
as String,facilityTypes: null == facilityTypes ? _self._facilityTypes : facilityTypes // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: freezed == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String?,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,province: null == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,whatsappPhone: freezed == whatsappPhone ? _self.whatsappPhone : whatsappPhone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,acceptedMedicalAidSchemeKeys: null == acceptedMedicalAidSchemeKeys ? _self._acceptedMedicalAidSchemeKeys : acceptedMedicalAidSchemeKeys // ignore: cast_nullable_to_non_nullable
as List<String>,acceptsYourMedicalAid: null == acceptsYourMedicalAid ? _self.acceptsYourMedicalAid : acceptsYourMedicalAid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
