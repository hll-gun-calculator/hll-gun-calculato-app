// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CalculatingFunction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculatingFunctionUpData _$CalculatingFunctionUpDataFromJson(
        Map<String, dynamic> json) =>
    CalculatingFunctionUpData(
      name: json['name'] as String? ?? "none",
      path: json['path'] as String? ?? "",
    )..type = $enumDecode(_$CalculatingFunctionUpDataTypeEnumMap, json['type']);

Map<String, dynamic> _$CalculatingFunctionUpDataToJson(
        CalculatingFunctionUpData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'type': _$CalculatingFunctionUpDataTypeEnumMap[instance.type]!,
    };

const _$CalculatingFunctionUpDataTypeEnumMap = {
  CalculatingFunctionUpDataType.None: 'None',
  CalculatingFunctionUpDataType.Network: 'Network',
};

CalculatingFunction _$CalculatingFunctionFromJson(Map<String, dynamic> json) =>
    CalculatingFunction(
      name: json['name'] as String? ?? "none",
      version: json['version'] as String? ?? "0.0.1",
      child: json['child'] as Map<String, dynamic>?,
      author: json['author'] as String? ?? "none",
      website: json['website'] as String? ?? "",
      updataFunction: (json['updataFunction'] as List<dynamic>?)
              ?.map((e) =>
                  CalculatingFunctionUpData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCustom: json['isCustom'] as bool? ?? false,
      creationTime: json['creationTime'] == null
          ? null
          : DateTime.parse(json['creationTime'] as String),
    );

Map<String, dynamic> _$CalculatingFunctionToJson(
        CalculatingFunction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'child': instance.child,
      'author': instance.author,
      'website': instance.website,
      'updataFunction': instance.updataFunction,
      'creationTime': instance.creationTime.toIso8601String(),
      'isCustom': instance.isCustom,
    };
