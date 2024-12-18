

import 'package:flutter/material.dart';
import '/data/CalcResult.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'MapToI18n.dart';
import 'index.dart';

part 'Gun.g.dart';

/// 火炮信息
@JsonSerializable()
class Gun {
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String id;

  // 名称
  @StringOrMapConverter()
  dynamic name;

  // 描述
  @StringOrMapConverter()
  dynamic description;

  // 位置
  @JsonKey(toJson: OffsetAsList, fromJson: ListAsOffset)
  Offset offset;

  // 颜色
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color color;

  // 方向
  @JsonKey(toJson: MapInfoFactionInfoDirectionToJson)
  MapInfoFactionInfoDirection direction;

  // 阵营
  @JsonKey(includeFromJson: false, includeToJson: false)
  Factions? factions;

  late MapGunResult? result;

  Gun({
    this.name = "none",
    this.offset = const Offset(0, 0),
    this.color = Colors.yellow,
    this.direction = MapInfoFactionInfoDirection.Left,
    this.factions = Factions.None,
    this.result,
  }) {
    id = const Uuid().v5(
        Uuid.NAMESPACE_NIL,
        "Gun-$name-${offset.dx},${offset.dy}"
    );
  }

  static Offset ListAsOffset(List value) => Offset(double.parse(value.first.toString()), double.parse(value.last.toString()));

  static List OffsetAsList(Offset value) => [value.dx, value.dy];

  static String MapInfoFactionInfoDirectionToJson (MapInfoFactionInfoDirection direction) => direction.value;

  factory Gun.fromJson(Map<String, dynamic> json) => _$GunFromJson(json);

  Map<String, dynamic> toJson() => _$GunToJson(this);
}

/// 地图火炮结果
@JsonSerializable()
class MapGunResult extends CalcResult {
  // 输出角度
  double outputAngle;

  // 输入坐标
  @JsonKey(toJson: OffsetAsList, fromJson: ListAsOffset)
  Offset inputOffset;

  // 目标坐标
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
