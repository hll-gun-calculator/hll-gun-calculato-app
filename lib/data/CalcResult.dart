import 'package:json_annotation/json_annotation.dart';

import 'Factions.dart';
import 'CalculatingFunction.dart';

part 'CalcResult.g.dart';

@JsonSerializable()
class CalcResult {
  // 输入阵营
  Factions inputFactions;

  // 输入值
  String inputValue;

  // 输出值
  String outputValue;

  // 创建时间
  DateTime? creationTime;

  // 函数信息
  @JsonKey(toJson: ValueToJson)
  late CalculatingFunction calculatingFunctionInfo;

  // 返回消息
  @JsonKey(toJson: ValueToJson)
  CalcResultStatus? result = CalcResultStatus();

  CalcResult({
    this.inputFactions = Factions.None,
    this.inputValue = "0",
    this.outputValue = "0",
    CalculatingFunction? calculatingFunctionInfo,
    CalcResultStatus? result,
  }) {
    this.calculatingFunctionInfo = calculatingFunctionInfo ?? CalculatingFunction();
    this.result = result ?? CalcResultStatus(message: "", code: 0);
    creationTime = DateTime.now();
  }

  static Map ValueToJson(dynamic value) => value.toJson();

  factory CalcResult.fromJson(Map<String, dynamic> json) => _$CalcResultFromJson(json);

  Map<String, dynamic> toJson() => _$CalcResultToJson(this);
}

@JsonSerializable()
class CalcResultStatus {
  String? message;
  num? code;

  CalcResultStatus({
    this.message,
    this.code,
  });

  factory CalcResultStatus.fromJson(Map<String, dynamic> json) => _$CalcResultStatusFromJson(json);

  Map<String, dynamic> toJson() => _$CalcResultStatusToJson(this);
}
