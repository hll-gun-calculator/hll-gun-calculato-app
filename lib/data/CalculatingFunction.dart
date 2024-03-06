import 'package:json_annotation/json_annotation.dart';

part 'CalculatingFunction.g.dart';

/// 计算函数
@JsonSerializable()
class CalculatingFunction {
  final String name;
  final String version;
  final Map<String, dynamic>? child;
  final String author;
  final String website;
  late DateTime creationTime;
  late bool isCustom;

  CalculatingFunction({
    this.name = "none",
    this.version = "0.0.1",
    this.child,
    this.author = "",
    this.website = "",
    this.isCustom = false,
    DateTime? creationTime,
  }) {
    this.creationTime = creationTime ?? DateTime.now();
  }

  factory CalculatingFunction.fromJson(Map<String, dynamic> json) => _$CalculatingFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatingFunctionToJson(this);
}
