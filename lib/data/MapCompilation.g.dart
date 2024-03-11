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
    );

Map<String, dynamic> _$MapCompilationToJson(MapCompilation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'author': instance.author,
      'version': instance.version,
      'data': instance.data,
    };
