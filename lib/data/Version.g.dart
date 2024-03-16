// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewVersion _$NewVersionFromJson(Map<String, dynamic> json) => NewVersion(
      android: json['android'] == null
          ? null
          : VersionBuildValue.fromJson(json['android'] as Map<String, dynamic>),
      ios: json['ios'] == null
          ? null
          : VersionBuildValue.fromJson(json['ios'] as Map<String, dynamic>),
      web: json['web'] == null
          ? null
          : VersionBuildValue.fromJson(json['web'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NewVersionToJson(NewVersion instance) =>
    <String, dynamic>{
      'android': instance.android,
      'ios': instance.ios,
      'web': instance.web,
    };

Versions _$VersionsFromJson(Map<String, dynamic> json) => Versions(
      list: (json['list'] as List<dynamic>?)
              ?.map((e) => VersionsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$VersionsToJson(Versions instance) => <String, dynamic>{
      'list': instance.list,
    };

VersionsItem _$VersionsItemFromJson(Map<String, dynamic> json) => VersionsItem(
      version: json['version'] as String?,
      system: (json['system'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry($enumDecode(_$VersionSystemTypeEnumMap, k),
                VersionBuildValue.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      platform: json['platform'] as Map<String, dynamic>? ?? const {},
      content: json['content'] as String?,
    );

Map<String, dynamic> _$VersionsItemToJson(VersionsItem instance) =>
    <String, dynamic>{
      'version': instance.version,
      'system': instance.system
          .map((k, e) => MapEntry(_$VersionSystemTypeEnumMap[k]!, e)),
      'platform': instance.platform,
      'content': instance.content,
    };

const _$VersionSystemTypeEnumMap = {
  VersionSystemType.None: 'None',
  VersionSystemType.Android: 'Android',
  VersionSystemType.Ios: 'Ios',
  VersionSystemType.Web: 'Web',
};

VersionBuildValue _$VersionBuildValueFromJson(Map<String, dynamic> json) =>
    VersionBuildValue(
      version: json['version'] as String?,
      buildNumber: json['buildNumber'] as String?,
    );

Map<String, dynamic> _$VersionBuildValueToJson(VersionBuildValue instance) =>
    <String, dynamic>{
      'version': instance.version,
      'buildNumber': instance.buildNumber,
    };
