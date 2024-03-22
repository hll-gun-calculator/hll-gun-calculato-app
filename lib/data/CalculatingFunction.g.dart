// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CalculatingFunction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculatingFunction _$CalculatingFunctionFromJson(Map<String, dynamic> json) =>
    CalculatingFunction(
      name: json['name'] as String? ?? "none",
      version: json['version'] as String? ?? "0.0.1",
      child: (json['child'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry($enumDecode(_$FactionsEnumMap, k),
                CalculatingFunctionChild.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      author: json['author'] as String? ?? "none",
      website: json['website'] as String? ?? "",
      updataFunction: (json['updataFunction'] as List<dynamic>?)
              ?.map((e) => UpdataFunction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      type:
          $enumDecodeNullable(_$CalculatingFunctionTypeEnumMap, json['type']) ??
              CalculatingFunctionType.Internal,
      id: json['id'] as String? ?? "none",
      creationTime: json['creationTime'] == null
          ? null
          : DateTime.parse(json['creationTime'] as String),
    )..description = _$JsonConverterFromJson<Object, dynamic>(
        json['description'], const StringOrMapConverter().fromJson);

Map<String, dynamic> _$CalculatingFunctionToJson(
        CalculatingFunction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': const StringOrMapConverter().toJson(instance.description),
      'version': instance.version,
      'child': CalculatingFunction.ChildToJson(instance.child),
      'author': instance.author,
      'website': instance.website,
      'updataFunction': instance.updataFunction,
      'creationTime': instance.creationTime.toIso8601String(),
      'type': _$CalculatingFunctionTypeEnumMap[instance.type]!,
      'id': instance.id,
    };

const _$FactionsEnumMap = {
  Factions.None: 'None',
  Factions.UnitedStates: 'UnitedStates',
  Factions.Germany: 'Germany',
  Factions.TheSovietUnion: 'TheSovietUnion',
  Factions.GreatBritain: 'GreatBritain',
};

const _$CalculatingFunctionTypeEnumMap = {
  CalculatingFunctionType.Internal: 'Internal',
  CalculatingFunctionType.Custom: 'Custom',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

CalculatingFunctionChild _$CalculatingFunctionChildFromJson(
        Map<String, dynamic> json) =>
    CalculatingFunctionChild(
      maximumRange:
          CalculatingFunctionChild.readValue(json, 'maximumRange') ?? 1600,
      minimumRange:
          CalculatingFunctionChild.readValue(json, 'minimumRange') ?? 100,
      envs: json['envs'] as Map<String, dynamic>? ?? {},
      fun: json['fun'] as String? ?? '',
    );

Map<String, dynamic> _$CalculatingFunctionChildToJson(
        CalculatingFunctionChild instance) =>
    <String, dynamic>{
      'maximumRange': instance.maximumRange,
      'minimumRange': instance.minimumRange,
      'envs': instance.envs,
      'fun': instance.fun,
    };
