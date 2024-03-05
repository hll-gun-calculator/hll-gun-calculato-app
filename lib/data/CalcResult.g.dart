// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CalcResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalcResult _$CalcResultFromJson(Map<String, dynamic> json) => CalcResult(
      inputFactions:
          $enumDecodeNullable(_$FactionsEnumMap, json['inputFactions']) ??
              Factions.None,
      inputValue: json['inputValue'] as String? ?? "0",
      outputValue: json['outputValue'] as String? ?? "0",
      calculatingFunctionInfo: json['calculatingFunctionInfo'] == null
          ? null
          : CalculatingFunction.fromJson(
              json['calculatingFunctionInfo'] as Map<String, dynamic>),
      result: json['result'] == null
          ? null
          : CalcResultStatus.fromJson(json['result'] as Map<String, dynamic>),
    )..creationTime = json['creationTime'] == null
        ? null
        : DateTime.parse(json['creationTime'] as String);

Map<String, dynamic> _$CalcResultToJson(CalcResult instance) =>
    <String, dynamic>{
      'inputFactions': _$FactionsEnumMap[instance.inputFactions]!,
      'inputValue': instance.inputValue,
      'outputValue': instance.outputValue,
      'creationTime': instance.creationTime?.toIso8601String(),
      'calculatingFunctionInfo':
          CalcResult.ValueToJson(instance.calculatingFunctionInfo),
      'result': CalcResult.ValueToJson(instance.result),
    };

const _$FactionsEnumMap = {
  Factions.None: 'None',
  Factions.America: 'America',
  Factions.Germany: 'Germany',
  Factions.TheSovietUnion: 'TheSovietUnion',
  Factions.GreatBritain: 'GreatBritain',
};

CalcResultStatus _$CalcResultStatusFromJson(Map<String, dynamic> json) =>
    CalcResultStatus(
      message: json['message'] as String?,
      code: json['code'] as num?,
    );

Map<String, dynamic> _$CalcResultStatusToJson(CalcResultStatus instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
    };
