// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'working_hours_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkingHoursEntry {

 String get day; String? get hours; bool get isClosed;
/// Create a copy of WorkingHoursEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkingHoursEntryCopyWith<WorkingHoursEntry> get copyWith => _$WorkingHoursEntryCopyWithImpl<WorkingHoursEntry>(this as WorkingHoursEntry, _$identity);

  /// Serializes this WorkingHoursEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkingHoursEntry&&(identical(other.day, day) || other.day == day)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.isClosed, isClosed) || other.isClosed == isClosed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,hours,isClosed);

@override
String toString() {
  return 'WorkingHoursEntry(day: $day, hours: $hours, isClosed: $isClosed)';
}


}

/// @nodoc
abstract mixin class $WorkingHoursEntryCopyWith<$Res>  {
  factory $WorkingHoursEntryCopyWith(WorkingHoursEntry value, $Res Function(WorkingHoursEntry) _then) = _$WorkingHoursEntryCopyWithImpl;
@useResult
$Res call({
 String day, String? hours, bool isClosed
});




}
/// @nodoc
class _$WorkingHoursEntryCopyWithImpl<$Res>
    implements $WorkingHoursEntryCopyWith<$Res> {
  _$WorkingHoursEntryCopyWithImpl(this._self, this._then);

  final WorkingHoursEntry _self;
  final $Res Function(WorkingHoursEntry) _then;

/// Create a copy of WorkingHoursEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? hours = freezed,Object? isClosed = null,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,hours: freezed == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as String?,isClosed: null == isClosed ? _self.isClosed : isClosed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkingHoursEntry].
extension WorkingHoursEntryPatterns on WorkingHoursEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkingHoursEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkingHoursEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkingHoursEntry value)  $default,){
final _that = this;
switch (_that) {
case _WorkingHoursEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkingHoursEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WorkingHoursEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  String? hours,  bool isClosed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkingHoursEntry() when $default != null:
return $default(_that.day,_that.hours,_that.isClosed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  String? hours,  bool isClosed)  $default,) {final _that = this;
switch (_that) {
case _WorkingHoursEntry():
return $default(_that.day,_that.hours,_that.isClosed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  String? hours,  bool isClosed)?  $default,) {final _that = this;
switch (_that) {
case _WorkingHoursEntry() when $default != null:
return $default(_that.day,_that.hours,_that.isClosed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkingHoursEntry implements WorkingHoursEntry {
  const _WorkingHoursEntry({required this.day, this.hours, this.isClosed = false});
  factory _WorkingHoursEntry.fromJson(Map<String, dynamic> json) => _$WorkingHoursEntryFromJson(json);

@override final  String day;
@override final  String? hours;
@override@JsonKey() final  bool isClosed;

/// Create a copy of WorkingHoursEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkingHoursEntryCopyWith<_WorkingHoursEntry> get copyWith => __$WorkingHoursEntryCopyWithImpl<_WorkingHoursEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkingHoursEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkingHoursEntry&&(identical(other.day, day) || other.day == day)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.isClosed, isClosed) || other.isClosed == isClosed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,hours,isClosed);

@override
String toString() {
  return 'WorkingHoursEntry(day: $day, hours: $hours, isClosed: $isClosed)';
}


}

/// @nodoc
abstract mixin class _$WorkingHoursEntryCopyWith<$Res> implements $WorkingHoursEntryCopyWith<$Res> {
  factory _$WorkingHoursEntryCopyWith(_WorkingHoursEntry value, $Res Function(_WorkingHoursEntry) _then) = __$WorkingHoursEntryCopyWithImpl;
@override @useResult
$Res call({
 String day, String? hours, bool isClosed
});




}
/// @nodoc
class __$WorkingHoursEntryCopyWithImpl<$Res>
    implements _$WorkingHoursEntryCopyWith<$Res> {
  __$WorkingHoursEntryCopyWithImpl(this._self, this._then);

  final _WorkingHoursEntry _self;
  final $Res Function(_WorkingHoursEntry) _then;

/// Create a copy of WorkingHoursEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? hours = freezed,Object? isClosed = null,}) {
  return _then(_WorkingHoursEntry(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,hours: freezed == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as String?,isClosed: null == isClosed ? _self.isClosed : isClosed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
