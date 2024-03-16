import 'package:json_annotation/json_annotation.dart';

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
}

/// 当前版本
@JsonSerializable()
class NewVersion {
  late VersionBuildValue android;

  late VersionBuildValue ios;

  late VersionBuildValue web;

  NewVersion({
    VersionBuildValue? android,
    VersionBuildValue? ios,
    VersionBuildValue? web,
  }) {
    this.android = android ?? VersionBuildValue();
    this.android = ios ?? VersionBuildValue();
    this.android = web ?? VersionBuildValue();
  }

  factory NewVersion.fromJson(Map<String, dynamic> json) => _$NewVersionFromJson(json);

  Map<String, dynamic> toJson() => _$NewVersionToJson(this);
}

/// 版本列表
@JsonSerializable()
class Versions {
  List<VersionsItem> list;

  Versions({this.list = const []});

  factory Versions.fromJson(Map<String, dynamic> json) => _$VersionsFromJson(json);

  Map<String, dynamic> toJson() => _$VersionsToJson(this);
}

@JsonSerializable()
class VersionsItem {
  late String version;

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
