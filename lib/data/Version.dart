import 'package:json_annotation/json_annotation.dart';

import 'index.dart';

part 'Version.g.dart';

String defultVersion = "0.0.0";
String defultBuildNumber = "0.0.0.0";

enum VersionSystemType {
  None(value: "none"),
  Android(value: "android"),
  Ios(value: "ios"),
  Web(value: "web");

  final String value;

  const VersionSystemType({
    required this.value,
  });

  static VersionSystemType parse(dynamic i) {
    if (i is int) {
      if (i == -1) return VersionSystemType.None;
      return VersionSystemType.values[i];
    }

    if (i is String && VersionSystemType.values.where((i) => i.value == i).isNotEmpty) {
      return VersionSystemType.values.where((i) => i.value == i).first;
    }

    return VersionSystemType.None;
  }
}

/// 当前版本
@JsonSerializable()
class NewVersion extends LoadingStatus {
  @JsonKey(toJson: ValueToJson)
  late VersionBuildValue android;

  @JsonKey(toJson: ValueToJson)
  late VersionBuildValue ios;

  @JsonKey(toJson: ValueToJson)
  late VersionBuildValue web;

  NewVersion({
    VersionBuildValue? android,
    VersionBuildValue? ios,
    VersionBuildValue? web,
  }) {
    this.android = android ?? VersionBuildValue();
    this.ios = ios ?? VersionBuildValue();
    this.web = web ?? VersionBuildValue();
  }

  static Map ValueToJson (VersionBuildValue value) => value.toJson();

  factory NewVersion.fromJson(Map<String, dynamic> json) => _$NewVersionFromJson(json);

  Map<String, dynamic> toJson() => _$NewVersionToJson(this);
}

/// 版本列表
@JsonSerializable()
class Versions extends LoadingStatus {
  List<VersionsItem> list;

  Versions({this.list = const []});

  factory Versions.fromJson(Map<String, dynamic> json) => _$VersionsFromJson(json);

  Map<String, dynamic> toJson() => _$VersionsToJson(this);
}

@JsonSerializable()
class VersionsItem {
  late String version;

  @JsonKey(toJson: systemToJson, fromJson: systemFromJson)
  Map<VersionSystemType, VersionBuildValue> system;

  Map platform;

  late String? content;

  VersionsItem({
    String? version,
    this.system = const {},
    this.platform = const {},
    this.content,
  }) {
    this.version = version ?? defultVersion;
  }

  static Map systemToJson (Map<VersionSystemType, VersionBuildValue> value) => value.map((key, value) => MapEntry(key.value, value.toJson()));

  static Map<VersionSystemType, VersionBuildValue> systemFromJson(Map factions) {
    Map<VersionSystemType, VersionBuildValue> map = {};
    factions.forEach((key, value) {
      map.addAll({VersionSystemType.parse(key): VersionBuildValue.fromJson(value)});
    });
    return map;
  }

  factory VersionsItem.fromJson(Map<String, dynamic> json) => _$VersionsItemFromJson(json);

  Map<String, dynamic> toJson() => _$VersionsItemToJson(this);
}

@JsonSerializable()
class VersionBuildValue {
  late String version;
  late String buildNumber;

  VersionBuildValue({
    String? version,
    String? buildNumber,
  }) {
    this.version = version ?? defultVersion;
    this.buildNumber = buildNumber ?? defultBuildNumber;
  }

  factory VersionBuildValue.fromJson(Map<String, dynamic> json) => _$VersionBuildValueFromJson(json);

  Map<String, dynamic> toJson() => _$VersionBuildValueToJson(this);
}
