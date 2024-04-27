// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GuideRecommendedBase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuideRecommendedBase _$GuideRecommendedBaseFromJson(
        Map<String, dynamic> json) =>
    GuideRecommendedBase(
      child: (json['child'] as List<dynamic>?)
              ?.map((e) =>
                  GuideRecommendedBaseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GuideRecommendedBaseToJson(
        GuideRecommendedBase instance) =>
    <String, dynamic>{
      'child': instance.child,
    };

GuideRecommendedBaseItem _$GuideRecommendedBaseItemFromJson(
        Map<String, dynamic> json) =>
    GuideRecommendedBaseItem(
      name: json['name'] as String? ?? "none",
      description: _$JsonConverterFromJson<Object, dynamic>(
          json['description'], const StringOrMapConverter().fromJson),
      updataFunction: json['updataFunction'] == null
          ? const []
          : GuideRecommendedBaseItem.updataFunctionFromJson(
              json['updataFunction'] as List),
    );

Map<String, dynamic> _$GuideRecommendedBaseItemToJson(
        GuideRecommendedBaseItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': const StringOrMapConverter().toJson(instance.description),
      'updataFunction': GuideRecommendedBaseItem.updataFunctionToJson(
          instance.updataFunction),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

GuideRecommendedCalcFunction _$GuideRecommendedCalcFunctionFromJson(
        Map<String, dynamic> json) =>
    GuideRecommendedCalcFunction()
      ..child = (json['child'] as List<dynamic>)
          .map((e) =>
              GuideRecommendedBaseItem.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$GuideRecommendedCalcFunctionToJson(
        GuideRecommendedCalcFunction instance) =>
    <String, dynamic>{
      'child': instance.child,
    };

GuideRecommendedMap _$GuideRecommendedMapFromJson(Map<String, dynamic> json) =>
    GuideRecommendedMap()
      ..child = (json['child'] as List<dynamic>)
          .map((e) =>
              GuideRecommendedBaseItem.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$GuideRecommendedMapToJson(
        GuideRecommendedMap instance) =>
    <String, dynamic>{
      'child': instance.child,
    };
