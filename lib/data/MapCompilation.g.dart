// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MapCompilation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapCompilation _$MapCompilationFromJson(Map<String, dynamic> json) =>
    MapCompilation(
      name: json['name'] as String? ?? "none",
      author: json['author'] as String? ?? "none",
      version: json['version'] as String? ?? "0.0.1",
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => MapInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    )..description = _$JsonConverterFromJson<Object, dynamic>(
        json['description'], const StringOrMapConverter().fromJson);

Map<String, dynamic> _$MapCompilationToJson(MapCompilation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': const StringOrMapConverter().toJson(instance.description),
      'author': instance.author,
      'version': instance.version,
      'data': instance.data,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
