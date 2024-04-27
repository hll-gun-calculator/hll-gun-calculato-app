// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MapCompilation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapCompilation _$MapCompilationFromJson(Map<String, dynamic> json) =>
    MapCompilation(
      id: json['id'] as String? ?? "",
      name: json['name'] as String? ?? "none",
      description: _$JsonConverterFromJson<Object, dynamic>(
              json['description'], const StringOrMapConverter().fromJson) ??
          "",
      author: json['author'] as String? ?? "none",
      version: json['version'] as String? ?? "0.0.1",
      updataFunction: json['updataFunction'] == null
          ? const []
          : MapCompilation.updataFunctionFromJson(
              json['updataFunction'] as List),
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => MapInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      type: $enumDecodeNullable(_$MapCompilationTypeEnumMap, json['type']) ??
          MapCompilationType.None,
    );

Map<String, dynamic> _$MapCompilationToJson(MapCompilation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': const StringOrMapConverter().toJson(instance.description),
      'author': instance.author,
      'version': instance.version,
      'updataFunction':
          MapCompilation.updataFunctionToJson(instance.updataFunction),
      'data': MapCompilation.dataToJson(instance.data),
      'type': _$MapCompilationTypeEnumMap[instance.type]!,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

const _$MapCompilationTypeEnumMap = {
  MapCompilationType.None: 'None',
  MapCompilationType.Custom: 'Custom',
};
