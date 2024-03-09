import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

import 'Factions.dart';

part 'CalculatingFunction.g.dart';

enum CalculatingFunctionUpDataType { None, Network }

@JsonSerializable()
class CalculatingFunctionUpData {
  String name;
  String path;
  @JsonKey(includeFromJson: false, includeToJson: false)
  CalculatingFunctionUpDataType type = CalculatingFunctionUpDataType.Network;

  CalculatingFunctionUpData({
    this.name = "none",
    this.path = "",
  });

  factory CalculatingFunctionUpData.fromJson(Map<String, dynamic> json) => _$CalculatingFunctionUpDataFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatingFunctionUpDataToJson(this);
}

enum CalculatingFunctionType { Internal, Custom }

/// 计算函数
@JsonSerializable()
class CalculatingFunction {
  // 名称
  late String name;

  // 版本
  late String version;

  // 阵营
  // final Map<String, dynamic>? child;
  final Map<Factions, CalculatingFunctionChild>? child;

  // 作者
  late String author;

  // 网站
  late String website;

  // 更新地址
  late List<CalculatingFunctionUpData>? updataFunction;

  // 创建时间
  late DateTime creationTime;

  // 是否自定义配置(内置或自定义)
  late CalculatingFunctionType type;

  late String id;

  CalculatingFunction({
    this.name = "none",
    this.version = "0.0.1",
    this.child,
    this.author = "none",
    this.website = "",
    this.updataFunction = const [],
    this.type = CalculatingFunctionType.Internal,
    DateTime? creationTime,
  }) {
    this.creationTime = creationTime ?? DateTime.now();
    this.id = const Uuid().v5(
      Uuid.NAMESPACE_NIL,
      "CalculatingFunction",
    );
  }

  bool hasChildValue(Factions faction) => child![faction] != null;

  CalculatingFunctionChild? childValue(Factions faction) => hasChildValue(faction) ? child![faction] : CalculatingFunctionChild(maximumRange: 1600, minimumRange: 100, envs: {}, fun: "");

  factory CalculatingFunction.fromJson(Map<String, dynamic> json) => _$CalculatingFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatingFunctionToJson(this);
}

@JsonSerializable()
class CalculatingFunctionChild {
  @JsonKey(readValue: readValue, defaultValue: 1600)
  late dynamic maximumRange = 1600;
  @JsonKey(readValue: readValue, defaultValue: 100)
  late dynamic minimumRange = 100;
  @JsonKey(defaultValue: {})
  late Map envs;
  @JsonKey(defaultValue: "")
  late String fun;

  CalculatingFunctionChild({
    required this.maximumRange,
    required this.minimumRange,
    required this.envs,
    required this.fun,
  });

  static num readValue(map, dynamic value) => num.parse(map[value].toString());

  factory CalculatingFunctionChild.fromJson(Map<String, dynamic> json) => _$CalculatingFunctionChildFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatingFunctionChildToJson(this);
}
