// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_hours_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkingHoursEntry _$WorkingHoursEntryFromJson(Map<String, dynamic> json) =>
    _WorkingHoursEntry(
      day: json['day'] as String,
      hours: json['hours'] as String?,
      isClosed: json['isClosed'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkingHoursEntryToJson(_WorkingHoursEntry instance) =>
    <String, dynamic>{
      'day': instance.day,
      'hours': instance.hours,
      'isClosed': instance.isClosed,
    };
