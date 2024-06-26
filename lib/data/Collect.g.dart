// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Collect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectItemData _$CollectItemDataFromJson(Map<String, dynamic> json) =>
    CollectItemData(
      id: json['id'] as String? ?? "",
      title: json['title'] as String? ?? "",
      remark: json['remark'] as String? ?? "",
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
      mapInfo: json['mapInfo'] == null
          ? null
          : MapInfo.fromJson(json['mapInfo'] as Map<String, dynamic>),
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

Map<String, dynamic> _$CollectItemDataToJson(CollectItemData instance) =>
    <String, dynamic>{
      'inputFactions': _$FactionsEnumMap[instance.inputFactions]!,
      'inputValue': instance.inputValue,
      'outputValue': instance.outputValue,
      'creationTime': instance.creationTime?.toIso8601String(),
      'calculatingFunctionInfo':
          CalcResult.ValueToJson(instance.calculatingFunctionInfo),
      'result': CalcResult.ValueToJson(instance.result),
      'id': instance.id,
      'title': instance.title,
      'remark': instance.remark,
      'updateTime': instance.updateTime?.toIso8601String(),
      'mapInfo': instance.mapInfo,
    };

const _$FactionsEnumMap = {
  Factions.None: 'None',
  Factions.UnitedStates: 'UnitedStates',
  Factions.Germany: 'Germany',
  Factions.TheSovietUnion: 'TheSovietUnion',
  Factions.GreatBritain: 'GreatBritain',
};
