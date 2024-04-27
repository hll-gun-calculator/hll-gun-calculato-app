import 'package:json_annotation/json_annotation.dart';

import 'UpdataFunction.dart';

@JsonSerializable()
class UpdataFunctionBaseClass {
  static List updataFunctionToJson (List<UpdataFunction> values) => values.map((e) => e.toJson()).toList();

  static List<UpdataFunction> updataFunctionFromJson (List values) => values.map((e) => UpdataFunction.fromJson(e)).toList();
}