// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CalculatingFunction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculatingFunction _$CalculatingFunctionFromJson(Map<String, dynamic> json) =>
    CalculatingFunction(
      name: json['name'] as String? ?? "none",
      version: json['version'] as String? ?? "0.0.1",
      child: json['child'] as Map<String, dynamic>?,
      author: json['author'] as String? ?? "",
      website: json['website'] as String? ?? "",
    );

Map<String, dynamic> _$CalculatingFunctionToJson(
        CalculatingFunction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'child': instance.child,
      'author': instance.author,
      'website': instance.website,
    };
