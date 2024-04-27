import 'package:hll_gun_calculator/data/UpdataFunctionBaseClass.dart';
import 'package:json_annotation/json_annotation.dart';

import 'MapToI18n.dart';
import 'index.dart';

part 'GuideRecommendedBase.g.dart';

@JsonSerializable()
class GuideRecommendedBase {
  List<GuideRecommendedBaseItem> child;

  GuideRecommendedBase({
    this.child = const [],
  });

  factory GuideRecommendedBase.fromJson(Map<String, dynamic> json) => _$GuideRecommendedBaseFromJson(json);

  Map<String, dynamic> toJson() => _$GuideRecommendedBaseToJson(this);
}

@JsonSerializable()
class GuideRecommendedBaseItem {
  // 名称
  @StringOrMapConverter()
  String name;

  // 描述
  @StringOrMapConverter()
  dynamic description;

  // 更新地址
  @JsonKey(toJson: updataFunctionToJson, fromJson: updataFunctionFromJson)
  late List<UpdataFunction> updataFunction;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late bool load;

  GuideRecommendedBaseItem({
    this.name = "none",
    this.description,
    this.updataFunction = const [],
    this.load = false,
  });

  static List updataFunctionToJson (List<UpdataFunction> values) => values.map((e) => e.toJson()).toList();

  static List<UpdataFunction> updataFunctionFromJson (List values) => values.map((e) => UpdataFunction.fromJson(e)).toList();

  factory GuideRecommendedBaseItem.fromJson(Map<String, dynamic> json) => _$GuideRecommendedBaseItemFromJson(json);

  Map<String, dynamic> toJson() => _$GuideRecommendedBaseItemToJson(this);
}

@JsonSerializable()
class GuideRecommendedCalcFunction extends GuideRecommendedBase {
  GuideRecommendedCalcFunction() : super();

  factory GuideRecommendedCalcFunction.fromJson(Map<String, dynamic> json) => _$GuideRecommendedCalcFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$GuideRecommendedCalcFunctionToJson(this);
}

@JsonSerializable()
class GuideRecommendedMap extends GuideRecommendedBase {
  GuideRecommendedMap() : super();

  factory GuideRecommendedMap.fromJson(Map<String, dynamic> json) => _$GuideRecommendedMapFromJson(json);

  Map<String, dynamic> toJson() => _$GuideRecommendedMapToJson(this);
}
