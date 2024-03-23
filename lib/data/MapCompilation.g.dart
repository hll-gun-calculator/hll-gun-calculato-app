// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MapCompilation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapCompilation _$MapCompilationFromJson(Map<String, dynamic> json) =>
    MapCompilation(
      name: json['name'] as String? ?? "none",
      description: _$JsonConverterFromJson<Object, dynamic>(
              json['description'], const StringOrMapConverter().fromJson) ??
          "",
      author: json['author'] as String? ?? "none",
      version: json['version'] as String? ?? "0.0.1",
      updataFunction: (json['updataFunction'] as List<dynamic>?)
              ?.map((e) => UpdataFunction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => MapInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      type: $enumDecodeNullable(_$MapCompilationTypeEnumMap, json['type']) ??
          MapCompilationType.None,
    );

Map<String, dynamic> _$MapCompilationToJson(MapCompilation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': const StringOrMapConverter().toJson(instance.description),
      'author': instance.author,
      'version': instance.version,
      'updataFunction': instance.updataFunction,
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
