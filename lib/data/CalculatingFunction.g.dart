// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CalculatingFunction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculatingFunction _$CalculatingFunctionFromJson(Map<String, dynamic> json) =>
    CalculatingFunction(
      id: json['id'] as String? ?? "",
      name: json['name'] as String? ?? "none",
      version: json['version'] as String? ?? "0.0.1",
      child: json['child'] == null
          ? const {}
          : CalculatingFunction.childFromJson(json['child'] as Map),
      author: json['author'] as String? ?? "none",
      website: json['website'] as String? ?? "",
      updataFunction: json['updataFunction'] == null
          ? const []
          : CalculatingFunction.updataFunctionFromJson(
              json['updataFunction'] as List),
      type:
          $enumDecodeNullable(_$CalculatingFunctionTypeEnumMap, json['type']) ??
              CalculatingFunctionType.Internal,
      creationTime: json['creationTime'] == null
          ? null
          : DateTime.parse(json['creationTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
    )..description = _$JsonConverterFromJson<Object, dynamic>(
        json['description'], const StringOrMapConverter().fromJson);

Map<String, dynamic> _$CalculatingFunctionToJson(
        CalculatingFunction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': const StringOrMapConverter().toJson(instance.description),
      'version': instance.version,
      'child': CalculatingFunction.childToJson(instance.child),
      'author': instance.author,
      'website': instance.website,
      'updataFunction':
          CalculatingFunction.updataFunctionToJson(instance.updataFunction),
      'creationTime': instance.creationTime.toIso8601String(),
      'updateTime': instance.updateTime.toIso8601String(),
      'type': _$CalculatingFunctionTypeEnumMap[instance.type]!,
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
