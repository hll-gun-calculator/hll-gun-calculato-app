import 'package:json_annotation/json_annotation.dart';

part 'UpdataFunction.g.dart';

enum CalculatingFunctionUpDataType { None, Network }

/// 更新
@JsonSerializable()
class UpdataFunction {
  // 名称
  String name;
  // 地址
  String path;

  @JsonKey(includeFromJson: false, includeToJson: false)
  CalculatingFunctionUpDataType type = CalculatingFunctionUpDataType.Network;

  UpdataFunction({
    this.name = "none",
    this.path = "",
  });

  factory UpdataFunction.fromJson(Map<String, dynamic> json) => _$UpdataFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$UpdataFunctionToJson(this);
}