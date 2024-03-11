import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hll_gun_calculator/data/CalcResult.dart';
import 'package:json_annotation/json_annotation.dart';

import 'index.dart';

part 'Gun.g.dart';

/// 火炮信息
@JsonSerializable()
class Gun {
  String name;

  @JsonKey(toJson: OffsetAsList, fromJson: ListAsOffset)
  Offset offset;

  Color color;

  @JsonKey(ignore: true)
  late MapGunResult? result;

  Gun({
    this.name = "none",
    this.offset = const Offset(0, 0),
    this.color = Colors.yellow,
    this.result,
  });

  static Offset ListAsOffset(List value) => Offset(double.parse(value.first.toString()), double.parse(value.last.toString()));

  static List OffsetAsList(Offset value) => [value.dx, value.dy];

  factory Gun.fromJson(Map<String, dynamic> json) => _$GunFromJson(json);

  Map<String, dynamic> toJson() => _$GunToJson(this);
}

/// 地图火炮结果
@JsonSerializable()
class MapGunResult extends CalcResult {
  @JsonKey(defaultValue: 0)
  double outputAngle;

  @JsonKey(toJson: OffsetAsList, fromJson: ListAsOffset)
  Offset inputOffset;

  @JsonKey(toJson: OffsetAsList, fromJson: ListAsOffset)
  Offset targetOffset;

  MapGunResult({
    this.outputAngle = 0,
    this.inputOffset = const Offset(-1, -1),
    this.targetOffset = const Offset(-1, -1),
  });

  static Offset ListAsOffset(List value) => Offset(double.parse(value.first.toString()), double.parse(value.last.toString()));

  static List OffsetAsList(Offset value) => [value.dx, value.dy];

  factory MapGunResult.fromJson(Map<String, dynamic> json) => _$MapGunResultFromJson(json);

  Map<String, dynamic> toJson() => _$MapGunResultToJson(this);
}
