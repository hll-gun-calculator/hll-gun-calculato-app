import 'package:json_annotation/json_annotation.dart';

part 'CalculatingFunction.g.dart';

enum CalculatingFunctionUpDataType { None, Network }

@JsonSerializable()
class CalculatingFunctionUpData {
  String name;
  String path;
  CalculatingFunctionUpDataType type = CalculatingFunctionUpDataType.Network;

  CalculatingFunctionUpData({
    this.name = "none",
    this.path = "",
  });

  factory CalculatingFunctionUpData.fromJson(Map<String, dynamic> json) => _$CalculatingFunctionUpDataFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatingFunctionUpDataToJson(this);
}

/// 计算函数
@JsonSerializable()
class CalculatingFunction {
  // 名称
  late String name;
  // 版本
  late String version;
  // 阵营
  final Map<String, dynamic>? child;
  // 作者
  late String author;
  // 网站
  late String website;
  // 更新地址
  late List<CalculatingFunctionUpData>? updataFunction;
  // 创建时间
  late DateTime creationTime;
  // 是否自定义配置(内置或自定义)
  late bool isCustom;

  CalculatingFunction({
    this.name = "none",
    this.version = "0.0.1",
    this.child,
    this.author = "none",
    this.website = "",
    this.updataFunction = const [],
    this.isCustom = false,
    DateTime? creationTime,
  }) {
    this.creationTime = creationTime ?? DateTime.now();
  }

  factory CalculatingFunction.fromJson(Map<String, dynamic> json) => _$CalculatingFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatingFunctionToJson(this);
}
