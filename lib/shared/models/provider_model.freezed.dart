// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProviderModel {

 String get id; String get name; String get categoryId; String? get specialty; String? get specialtyId; String? get facilityId; String? get facilityName; String? get address; String? get phone; double? get latitude; double? get longitude; double? get distanceKm; String? get hours; String? get imageUrl; String? get heroImageUrl; bool get isVerified; String? get mdpczNumber; String? get about; List<String> get services; List<WorkingHoursEntry> get weeklyHours; List<String> get conditions; List<String> get ageGroups; bool? get isOpenNow; bool? get isClosingSoon; bool? get emergencyAvailable; bool? get acceptsWalkIns; bool? get hasQueue; int? get queueLength; int? get waitEstimateMinutes; DateTime? get nextAvailableSlot; bool? get availableToday; double? get rating; int? get reviewCount; String? get verificationSource; bool get isClaimed;
/// Create a copy of ProviderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderModelCopyWith<ProviderModel> get copyWith => _$ProviderModelCopyWithImpl<ProviderModel>(this as ProviderModel, _$identity);

  /// Serializes this ProviderModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.specialtyId, specialtyId) || other.specialtyId == specialtyId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.mdpczNumber, mdpczNumber) || other.mdpczNumber == mdpczNumber)&&(identical(other.about, about) || other.about == about)&&const DeepCollectionEquality().equals(other.services, services)&&const DeepCollectionEquality().equals(other.weeklyHours, weeklyHours)&&const DeepCollectionEquality().equals(other.conditions, conditions)&&const DeepCollectionEquality().equals(other.ageGroups, ageGroups)&&(identical(other.isOpenNow, isOpenNow) || other.isOpenNow == isOpenNow)&&(identical(other.isClosingSoon, isClosingSoon) || other.isClosingSoon == isClosingSoon)&&(identical(other.emergencyAvailable, emergencyAvailable) || other.emergencyAvailable == emergencyAvailable)&&(identical(other.acceptsWalkIns, acceptsWalkIns) || other.acceptsWalkIns == acceptsWalkIns)&&(identical(other.hasQueue, hasQueue) || other.hasQueue == hasQueue)&&(identical(other.queueLength, queueLength) || other.queueLength == queueLength)&&(identical(other.waitEstimateMinutes, waitEstimateMinutes) || other.waitEstimateMinutes == waitEstimateMinutes)&&(identical(other.nextAvailableSlot, nextAvailableSlot) || other.nextAvailableSlot == nextAvailableSlot)&&(identical(other.availableToday, availableToday) || other.availableToday == availableToday)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.verificationSource, verificationSource) || other.verificationSource == verificationSource)&&(identical(other.isClaimed, isClaimed) || other.isClaimed == isClaimed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,categoryId,specialty,specialtyId,facilityId,facilityName,address,phone,latitude,longitude,distanceKm,hours,imageUrl,heroImageUrl,isVerified,mdpczNumber,about,const DeepCollectionEquality().hash(services),const DeepCollectionEquality().hash(weeklyHours),const DeepCollectionEquality().hash(conditions),const DeepCollectionEquality().hash(ageGroups),isOpenNow,isClosingSoon,emergencyAvailable,acceptsWalkIns,hasQueue,queueLength,waitEstimateMinutes,nextAvailableSlot,availableToday,rating,reviewCount,verificationSource,isClaimed]);

@override
String toString() {
  return 'ProviderModel(id: $id, name: $name, categoryId: $categoryId, specialty: $specialty, specialtyId: $specialtyId, facilityId: $facilityId, facilityName: $facilityName, address: $address, phone: $phone, latitude: $latitude, longitude: $longitude, distanceKm: $distanceKm, hours: $hours, imageUrl: $imageUrl, heroImageUrl: $heroImageUrl, isVerified: $isVerified, mdpczNumber: $mdpczNumber, about: $about, services: $services, weeklyHours: $weeklyHours, conditions: $conditions, ageGroups: $ageGroups, isOpenNow: $isOpenNow, isClosingSoon: $isClosingSoon, emergencyAvailable: $emergencyAvailable, acceptsWalkIns: $acceptsWalkIns, hasQueue: $hasQueue, queueLength: $queueLength, waitEstimateMinutes: $waitEstimateMinutes, nextAvailableSlot: $nextAvailableSlot, availableToday: $availableToday, rating: $rating, reviewCount: $reviewCount, verificationSource: $verificationSource, isClaimed: $isClaimed)';
}


}

/// @nodoc
abstract mixin class $ProviderModelCopyWith<$Res>  {
  factory $ProviderModelCopyWith(ProviderModel value, $Res Function(ProviderModel) _then) = _$ProviderModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String categoryId, String? specialty, String? specialtyId, String? facilityId, String? facilityName, String? address, String? phone, double? latitude, double? longitude, double? distanceKm, String? hours, String? imageUrl, String? heroImageUrl, bool isVerified, String? mdpczNumber, String? about, List<String> services, List<WorkingHoursEntry> weeklyHours, List<String> conditions, List<String> ageGroups, bool? isOpenNow, bool? isClosingSoon, bool? emergencyAvailable, bool? acceptsWalkIns, bool? hasQueue, int? queueLength, int? waitEstimateMinutes, DateTime? nextAvailableSlot, bool? availableToday, double? rating, int? reviewCount, String? verificationSource, bool isClaimed
});




}
/// @nodoc
class _$ProviderModelCopyWithImpl<$Res>
    implements $ProviderModelCopyWith<$Res> {
  _$ProviderModelCopyWithImpl(this._self, this._then);

  final ProviderModel _self;
  final $Res Function(ProviderModel) _then;

/// Create a copy of ProviderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? categoryId = null,Object? specialty = freezed,Object? specialtyId = freezed,Object? facilityId = freezed,Object? facilityName = freezed,Object? address = freezed,Object? phone = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? distanceKm = freezed,Object? hours = freezed,Object? imageUrl = freezed,Object? heroImageUrl = freezed,Object? isVerified = null,Object? mdpczNumber = freezed,Object? about = freezed,Object? services = null,Object? weeklyHours = null,Object? conditions = null,Object? ageGroups = null,Object? isOpenNow = freezed,Object? isClosingSoon = freezed,Object? emergencyAvailable = freezed,Object? acceptsWalkIns = freezed,Object? hasQueue = freezed,Object? queueLength = freezed,Object? waitEstimateMinutes = freezed,Object? nextAvailableSlot = freezed,Object? availableToday = freezed,Object? rating = freezed,Object? reviewCount = freezed,Object? verificationSource = freezed,Object? isClaimed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,specialty: freezed == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String?,specialtyId: freezed == specialtyId ? _self.specialtyId : specialtyId // ignore: cast_nullable_to_non_nullable
as String?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String?,facilityName: freezed == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,hours: freezed == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,heroImageUrl: freezed == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,mdpczNumber: freezed == mdpczNumber ? _self.mdpczNumber : mdpczNumber // ignore: cast_nullable_to_non_nullable
as String?,about: freezed == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as String?,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<String>,weeklyHours: null == weeklyHours ? _self.weeklyHours : weeklyHours // ignore: cast_nullable_to_non_nullable
as List<WorkingHoursEntry>,conditions: null == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<String>,ageGroups: null == ageGroups ? _self.ageGroups : ageGroups // ignore: cast_nullable_to_non_nullable
as List<String>,isOpenNow: freezed == isOpenNow ? _self.isOpenNow : isOpenNow // ignore: cast_nullable_to_non_nullable
as bool?,isClosingSoon: freezed == isClosingSoon ? _self.isClosingSoon : isClosingSoon // ignore: cast_nullable_to_non_nullable
as bool?,emergencyAvailable: freezed == emergencyAvailable ? _self.emergencyAvailable : emergencyAvailable // ignore: cast_nullable_to_non_nullable
as bool?,acceptsWalkIns: freezed == acceptsWalkIns ? _self.acceptsWalkIns : acceptsWalkIns // ignore: cast_nullable_to_non_nullable
as bool?,hasQueue: freezed == hasQueue ? _self.hasQueue : hasQueue // ignore: cast_nullable_to_non_nullable
as bool?,queueLength: freezed == queueLength ? _self.queueLength : queueLength // ignore: cast_nullable_to_non_nullable
as int?,waitEstimateMinutes: freezed == waitEstimateMinutes ? _self.waitEstimateMinutes : waitEstimateMinutes // ignore: cast_nullable_to_non_nullable
as int?,nextAvailableSlot: freezed == nextAvailableSlot ? _self.nextAvailableSlot : nextAvailableSlot // ignore: cast_nullable_to_non_nullable
as DateTime?,availableToday: freezed == availableToday ? _self.availableToday : availableToday // ignore: cast_nullable_to_non_nullable
as bool?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: freezed == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int?,verificationSource: freezed == verificationSource ? _self.verificationSource : verificationSource // ignore: cast_nullable_to_non_nullable
as String?,isClaimed: null == isClaimed ? _self.isClaimed : isClaimed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderModel].
extension ProviderModelPatterns on ProviderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderModel value)  $default,){
final _that = this;
switch (_that) {
case _ProviderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String categoryId,  String? specialty,  String? specialtyId,  String? facilityId,  String? facilityName,  String? address,  String? phone,  double? latitude,  double? longitude,  double? distanceKm,  String? hours,  String? imageUrl,  String? heroImageUrl,  bool isVerified,  String? mdpczNumber,  String? about,  List<String> services,  List<WorkingHoursEntry> weeklyHours,  List<String> conditions,  List<String> ageGroups,  bool? isOpenNow,  bool? isClosingSoon,  bool? emergencyAvailable,  bool? acceptsWalkIns,  bool? hasQueue,  int? queueLength,  int? waitEstimateMinutes,  DateTime? nextAvailableSlot,  bool? availableToday,  double? rating,  int? reviewCount,  String? verificationSource,  bool isClaimed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderModel() when $default != null:
return $default(_that.id,_that.name,_that.categoryId,_that.specialty,_that.specialtyId,_that.facilityId,_that.facilityName,_that.address,_that.phone,_that.latitude,_that.longitude,_that.distanceKm,_that.hours,_that.imageUrl,_that.heroImageUrl,_that.isVerified,_that.mdpczNumber,_that.about,_that.services,_that.weeklyHours,_that.conditions,_that.ageGroups,_that.isOpenNow,_that.isClosingSoon,_that.emergencyAvailable,_that.acceptsWalkIns,_that.hasQueue,_that.queueLength,_that.waitEstimateMinutes,_that.nextAvailableSlot,_that.availableToday,_that.rating,_that.reviewCount,_that.verificationSource,_that.isClaimed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String categoryId,  String? specialty,  String? specialtyId,  String? facilityId,  String? facilityName,  String? address,  String? phone,  double? latitude,  double? longitude,  double? distanceKm,  String? hours,  String? imageUrl,  String? heroImageUrl,  bool isVerified,  String? mdpczNumber,  String? about,  List<String> services,  List<WorkingHoursEntry> weeklyHours,  List<String> conditions,  List<String> ageGroups,  bool? isOpenNow,  bool? isClosingSoon,  bool? emergencyAvailable,  bool? acceptsWalkIns,  bool? hasQueue,  int? queueLength,  int? waitEstimateMinutes,  DateTime? nextAvailableSlot,  bool? availableToday,  double? rating,  int? reviewCount,  String? verificationSource,  bool isClaimed)  $default,) {final _that = this;
switch (_that) {
case _ProviderModel():
return $default(_that.id,_that.name,_that.categoryId,_that.specialty,_that.specialtyId,_that.facilityId,_that.facilityName,_that.address,_that.phone,_that.latitude,_that.longitude,_that.distanceKm,_that.hours,_that.imageUrl,_that.heroImageUrl,_that.isVerified,_that.mdpczNumber,_that.about,_that.services,_that.weeklyHours,_that.conditions,_that.ageGroups,_that.isOpenNow,_that.isClosingSoon,_that.emergencyAvailable,_that.acceptsWalkIns,_that.hasQueue,_that.queueLength,_that.waitEstimateMinutes,_that.nextAvailableSlot,_that.availableToday,_that.rating,_that.reviewCount,_that.verificationSource,_that.isClaimed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String categoryId,  String? specialty,  String? specialtyId,  String? facilityId,  String? facilityName,  String? address,  String? phone,  double? latitude,  double? longitude,  double? distanceKm,  String? hours,  String? imageUrl,  String? heroImageUrl,  bool isVerified,  String? mdpczNumber,  String? about,  List<String> services,  List<WorkingHoursEntry> weeklyHours,  List<String> conditions,  List<String> ageGroups,  bool? isOpenNow,  bool? isClosingSoon,  bool? emergencyAvailable,  bool? acceptsWalkIns,  bool? hasQueue,  int? queueLength,  int? waitEstimateMinutes,  DateTime? nextAvailableSlot,  bool? availableToday,  double? rating,  int? reviewCount,  String? verificationSource,  bool isClaimed)?  $default,) {final _that = this;
switch (_that) {
case _ProviderModel() when $default != null:
return $default(_that.id,_that.name,_that.categoryId,_that.specialty,_that.specialtyId,_that.facilityId,_that.facilityName,_that.address,_that.phone,_that.latitude,_that.longitude,_that.distanceKm,_that.hours,_that.imageUrl,_that.heroImageUrl,_that.isVerified,_that.mdpczNumber,_that.about,_that.services,_that.weeklyHours,_that.conditions,_that.ageGroups,_that.isOpenNow,_that.isClosingSoon,_that.emergencyAvailable,_that.acceptsWalkIns,_that.hasQueue,_that.queueLength,_that.waitEstimateMinutes,_that.nextAvailableSlot,_that.availableToday,_that.rating,_that.reviewCount,_that.verificationSource,_that.isClaimed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderModel implements ProviderModel {
  const _ProviderModel({required this.id, required this.name, required this.categoryId, this.specialty, this.specialtyId, this.facilityId, this.facilityName, this.address, this.phone, this.latitude, this.longitude, this.distanceKm, this.hours, this.imageUrl, this.heroImageUrl, this.isVerified = false, this.mdpczNumber, this.about, final  List<String> services = const [], final  List<WorkingHoursEntry> weeklyHours = const [], final  List<String> conditions = const [], final  List<String> ageGroups = const [], this.isOpenNow, this.isClosingSoon, this.emergencyAvailable, this.acceptsWalkIns, this.hasQueue, this.queueLength, this.waitEstimateMinutes, this.nextAvailableSlot, this.availableToday, this.rating, this.reviewCount, this.verificationSource, this.isClaimed = false}): _services = services,_weeklyHours = weeklyHours,_conditions = conditions,_ageGroups = ageGroups;
  factory _ProviderModel.fromJson(Map<String, dynamic> json) => _$ProviderModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String categoryId;
@override final  String? specialty;
@override final  String? specialtyId;
@override final  String? facilityId;
@override final  String? facilityName;
@override final  String? address;
@override final  String? phone;
@override final  double? latitude;
@override final  double? longitude;
@override final  double? distanceKm;
@override final  String? hours;
@override final  String? imageUrl;
@override final  String? heroImageUrl;
@override@JsonKey() final  bool isVerified;
@override final  String? mdpczNumber;
@override final  String? about;
 final  List<String> _services;
@override@JsonKey() List<String> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

 final  List<WorkingHoursEntry> _weeklyHours;
@override@JsonKey() List<WorkingHoursEntry> get weeklyHours {
  if (_weeklyHours is EqualUnmodifiableListView) return _weeklyHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeklyHours);
}

 final  List<String> _conditions;
@override@JsonKey() List<String> get conditions {
  if (_conditions is EqualUnmodifiableListView) return _conditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conditions);
}

 final  List<String> _ageGroups;
@override@JsonKey() List<String> get ageGroups {
  if (_ageGroups is EqualUnmodifiableListView) return _ageGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ageGroups);
}

@override final  bool? isOpenNow;
@override final  bool? isClosingSoon;
@override final  bool? emergencyAvailable;
@override final  bool? acceptsWalkIns;
@override final  bool? hasQueue;
@override final  int? queueLength;
@override final  int? waitEstimateMinutes;
@override final  DateTime? nextAvailableSlot;
@override final  bool? availableToday;
@override final  double? rating;
@override final  int? reviewCount;
@override final  String? verificationSource;
@override@JsonKey() final  bool isClaimed;

/// Create a copy of ProviderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderModelCopyWith<_ProviderModel> get copyWith => __$ProviderModelCopyWithImpl<_ProviderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.specialtyId, specialtyId) || other.specialtyId == specialtyId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.mdpczNumber, mdpczNumber) || other.mdpczNumber == mdpczNumber)&&(identical(other.about, about) || other.about == about)&&const DeepCollectionEquality().equals(other._services, _services)&&const DeepCollectionEquality().equals(other._weeklyHours, _weeklyHours)&&const DeepCollectionEquality().equals(other._conditions, _conditions)&&const DeepCollectionEquality().equals(other._ageGroups, _ageGroups)&&(identical(other.isOpenNow, isOpenNow) || other.isOpenNow == isOpenNow)&&(identical(other.isClosingSoon, isClosingSoon) || other.isClosingSoon == isClosingSoon)&&(identical(other.emergencyAvailable, emergencyAvailable) || other.emergencyAvailable == emergencyAvailable)&&(identical(other.acceptsWalkIns, acceptsWalkIns) || other.acceptsWalkIns == acceptsWalkIns)&&(identical(other.hasQueue, hasQueue) || other.hasQueue == hasQueue)&&(identical(other.queueLength, queueLength) || other.queueLength == queueLength)&&(identical(other.waitEstimateMinutes, waitEstimateMinutes) || other.waitEstimateMinutes == waitEstimateMinutes)&&(identical(other.nextAvailableSlot, nextAvailableSlot) || other.nextAvailableSlot == nextAvailableSlot)&&(identical(other.availableToday, availableToday) || other.availableToday == availableToday)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.verificationSource, verificationSource) || other.verificationSource == verificationSource)&&(identical(other.isClaimed, isClaimed) || other.isClaimed == isClaimed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,categoryId,specialty,specialtyId,facilityId,facilityName,address,phone,latitude,longitude,distanceKm,hours,imageUrl,heroImageUrl,isVerified,mdpczNumber,about,const DeepCollectionEquality().hash(_services),const DeepCollectionEquality().hash(_weeklyHours),const DeepCollectionEquality().hash(_conditions),const DeepCollectionEquality().hash(_ageGroups),isOpenNow,isClosingSoon,emergencyAvailable,acceptsWalkIns,hasQueue,queueLength,waitEstimateMinutes,nextAvailableSlot,availableToday,rating,reviewCount,verificationSource,isClaimed]);

@override
String toString() {
  return 'ProviderModel(id: $id, name: $name, categoryId: $categoryId, specialty: $specialty, specialtyId: $specialtyId, facilityId: $facilityId, facilityName: $facilityName, address: $address, phone: $phone, latitude: $latitude, longitude: $longitude, distanceKm: $distanceKm, hours: $hours, imageUrl: $imageUrl, heroImageUrl: $heroImageUrl, isVerified: $isVerified, mdpczNumber: $mdpczNumber, about: $about, services: $services, weeklyHours: $weeklyHours, conditions: $conditions, ageGroups: $ageGroups, isOpenNow: $isOpenNow, isClosingSoon: $isClosingSoon, emergencyAvailable: $emergencyAvailable, acceptsWalkIns: $acceptsWalkIns, hasQueue: $hasQueue, queueLength: $queueLength, waitEstimateMinutes: $waitEstimateMinutes, nextAvailableSlot: $nextAvailableSlot, availableToday: $availableToday, rating: $rating, reviewCount: $reviewCount, verificationSource: $verificationSource, isClaimed: $isClaimed)';
}


}

/// @nodoc
abstract mixin class _$ProviderModelCopyWith<$Res> implements $ProviderModelCopyWith<$Res> {
  factory _$ProviderModelCopyWith(_ProviderModel value, $Res Function(_ProviderModel) _then) = __$ProviderModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String categoryId, String? specialty, String? specialtyId, String? facilityId, String? facilityName, String? address, String? phone, double? latitude, double? longitude, double? distanceKm, String? hours, String? imageUrl, String? heroImageUrl, bool isVerified, String? mdpczNumber, String? about, List<String> services, List<WorkingHoursEntry> weeklyHours, List<String> conditions, List<String> ageGroups, bool? isOpenNow, bool? isClosingSoon, bool? emergencyAvailable, bool? acceptsWalkIns, bool? hasQueue, int? queueLength, int? waitEstimateMinutes, DateTime? nextAvailableSlot, bool? availableToday, double? rating, int? reviewCount, String? verificationSource, bool isClaimed
});




}
/// @nodoc
class __$ProviderModelCopyWithImpl<$Res>
    implements _$ProviderModelCopyWith<$Res> {
  __$ProviderModelCopyWithImpl(this._self, this._then);

  final _ProviderModel _self;
  final $Res Function(_ProviderModel) _then;

/// Create a copy of ProviderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? categoryId = null,Object? specialty = freezed,Object? specialtyId = freezed,Object? facilityId = freezed,Object? facilityName = freezed,Object? address = freezed,Object? phone = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? distanceKm = freezed,Object? hours = freezed,Object? imageUrl = freezed,Object? heroImageUrl = freezed,Object? isVerified = null,Object? mdpczNumber = freezed,Object? about = freezed,Object? services = null,Object? weeklyHours = null,Object? conditions = null,Object? ageGroups = null,Object? isOpenNow = freezed,Object? isClosingSoon = freezed,Object? emergencyAvailable = freezed,Object? acceptsWalkIns = freezed,Object? hasQueue = freezed,Object? queueLength = freezed,Object? waitEstimateMinutes = freezed,Object? nextAvailableSlot = freezed,Object? availableToday = freezed,Object? rating = freezed,Object? reviewCount = freezed,Object? verificationSource = freezed,Object? isClaimed = null,}) {
  return _then(_ProviderModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,specialty: freezed == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String?,specialtyId: freezed == specialtyId ? _self.specialtyId : specialtyId // ignore: cast_nullable_to_non_nullable
as String?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String?,facilityName: freezed == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,hours: freezed == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,heroImageUrl: freezed == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,mdpczNumber: freezed == mdpczNumber ? _self.mdpczNumber : mdpczNumber // ignore: cast_nullable_to_non_nullable
as String?,about: freezed == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as String?,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<String>,weeklyHours: null == weeklyHours ? _self._weeklyHours : weeklyHours // ignore: cast_nullable_to_non_nullable
as List<WorkingHoursEntry>,conditions: null == conditions ? _self._conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<String>,ageGroups: null == ageGroups ? _self._ageGroups : ageGroups // ignore: cast_nullable_to_non_nullable
as List<String>,isOpenNow: freezed == isOpenNow ? _self.isOpenNow : isOpenNow // ignore: cast_nullable_to_non_nullable
as bool?,isClosingSoon: freezed == isClosingSoon ? _self.isClosingSoon : isClosingSoon // ignore: cast_nullable_to_non_nullable
as bool?,emergencyAvailable: freezed == emergencyAvailable ? _self.emergencyAvailable : emergencyAvailable // ignore: cast_nullable_to_non_nullable
as bool?,acceptsWalkIns: freezed == acceptsWalkIns ? _self.acceptsWalkIns : acceptsWalkIns // ignore: cast_nullable_to_non_nullable
as bool?,hasQueue: freezed == hasQueue ? _self.hasQueue : hasQueue // ignore: cast_nullable_to_non_nullable
as bool?,queueLength: freezed == queueLength ? _self.queueLength : queueLength // ignore: cast_nullable_to_non_nullable
as int?,waitEstimateMinutes: freezed == waitEstimateMinutes ? _self.waitEstimateMinutes : waitEstimateMinutes // ignore: cast_nullable_to_non_nullable
as int?,nextAvailableSlot: freezed == nextAvailableSlot ? _self.nextAvailableSlot : nextAvailableSlot // ignore: cast_nullable_to_non_nullable
as DateTime?,availableToday: freezed == availableToday ? _self.availableToday : availableToday // ignore: cast_nullable_to_non_nullable
as bool?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: freezed == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int?,verificationSource: freezed == verificationSource ? _self.verificationSource : verificationSource // ignore: cast_nullable_to_non_nullable
as String?,isClaimed: null == isClaimed ? _self.isClaimed : isClaimed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
