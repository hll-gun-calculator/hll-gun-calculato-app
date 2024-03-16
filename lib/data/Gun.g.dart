// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Gun.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gun _$GunFromJson(Map<String, dynamic> json) => Gun(
      name: _$JsonConverterFromJson<Object, dynamic>(
              json['name'], const StringOrMapConverter().fromJson) ??
          "none",
      offset: json['offset'] == null
          ? const Offset(0, 0)
          : Gun.ListAsOffset(json['offset'] as List),
      result: json['result'] == null
          ? null
          : MapGunResult.fromJson(json['result'] as Map<String, dynamic>),
    )..description = _$JsonConverterFromJson<Object, dynamic>(
        json['description'], const StringOrMapConverter().fromJson);

Map<String, dynamic> _$GunToJson(Gun instance) => <String, dynamic>{
      'name': const StringOrMapConverter().toJson(instance.name),
      'description': const StringOrMapConverter().toJson(instance.description),
      'offset': Gun.OffsetAsList(instance.offset),
      'result': instance.result,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

MapGunResult _$MapGunResultFromJson(Map<String, dynamic> json) => MapGunResult(
      outputAngle: (json['outputAngle'] as num?)?.toDouble() ?? 0,
      inputOffset: json['inputOffset'] == null
          ? const Offset(-1, -1)
          : MapGunResult.ListAsOffset(json['inputOffset'] as List),
      targetOffset: json['targetOffset'] == null
          ? const Offset(-1, -1)
          : MapGunResult.ListAsOffset(json['targetOffset'] as List),
    )
      ..inputFactions = $enumDecode(_$FactionsEnumMap, json['inputFactions'])
      ..inputValue = json['inputValue'] as String
      ..outputValue = json['outputValue'] as String
      ..creationTime = json['creationTime'] == null
          ? null
          : DateTime.parse(json['creationTime'] as String)
      ..calculatingFunctionInfo = CalcResult.ValueCalculatingFunctionFromJson(
          json['calculatingFunctionInfo'])
      ..result = CalcResult.ValueCalcResultStatusFromJson(json['result']);

Map<String, dynamic> _$MapGunResultToJson(MapGunResult instance) =>
    <String, dynamic>{
      'inputFactions': _$FactionsEnumMap[instance.inputFactions]!,
      'inputValue': instance.inputValue,
      'outputValue': instance.outputValue,
      'creationTime': instance.creationTime?.toIso8601String(),
      'calculatingFunctionInfo':
          CalcResult.ValueToJson(instance.calculatingFunctionInfo),
      'result': CalcResult.ValueToJson(instance.result),
      'outputAngle': instance.outputAngle,
      'inputOffset': MapGunResult.OffsetAsList(instance.inputOffset),
      'targetOffset': MapGunResult.OffsetAsList(instance.targetOffset),
    };

const _$FactionsEnumMap = {
  Factions.None: 'None',
  Factions.America: 'America',
  Factions.Germany: 'Germany',
  Factions.TheSovietUnion: 'TheSovietUnion',
  Factions.GreatBritain: 'GreatBritain',
};
