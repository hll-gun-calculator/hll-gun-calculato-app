import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'MapToI18n.dart';
import 'index.dart';

part 'Map.g.dart';

@JsonSerializable()
class MapInfo {
  // 地图名称
  @StringOrMapConverter()
  final String name;

  // 描述
  @StringOrMapConverter()
  dynamic description;

  // 地图大小
  @JsonKey(toJson: OffsetAsList, fromJson: ListAsOffset)
  final Offset size;

  // 初始位置
  @JsonKey(toJson: OffsetAsList, fromJson: ListAsOffset)
  final Offset initialPosition;

  // 阵营，通常2名
  @JsonKey(toJson: factionsToJson, fromJson: factionsFromJson, defaultValue: {})
  late Map<Factions, MapInfoFactionInfo>? factions;

  // 地图底图-资源地址
  @JsonKey(toJson: assetsToJson, fromJson: assetsFromJson)
  final MapInfoAssets? assets;

  // 地图孩子-其他图层
  @JsonKey(toJson: childsToJson)
  final List<MapInfoAssets> childs;

  // 标记
  @JsonKey(toJson: markerToJson, fromJson: markerFromJson, defaultValue: [])
  final List<MapInfoMarkerItem>? marker;

  // 所有火炮列表
  List<Gun> get gunPositions {
    List<Gun> list = [];
    factions?.forEach((key, value) {
      for (Gun gun in value.gunPosition) {
        gun.direction = value.direction;
        gun.factions = key;
        list.add(gun);
      }
    });
    return list;
  }

  // 所有标记列表
  List<MapInfoMarkerItem_Fll> get markerPointAll {
    List<MapInfoMarkerItem_Fll> list = [];
    marker?.forEach((i) {
      for (var j in i.points) {
        list.add(MapInfoMarkerItem_Fll(
          upLevelName: i.name!,
          name: j.name,
          iconType: i.iconType,
          iconPath: i.iconPath,
          x: j.x,
          y: j.y,
        ));
      }
    });
    return list;
  }

  MapInfo({
    this.name = "none",
    this.description = "",
    this.size = const Offset(1000, 1000),
    this.initialPosition = const Offset(0, 0),
    this.factions,
    required this.assets,
    this.childs = const [],
    this.marker,
  });

  static Map factionsToJson(Map<Factions, MapInfoFactionInfo>? value) {
    return value!.map((key, value) => MapEntry(key.value, value.toJson()));
  }

  static Map assetsToJson(MapInfoAssets? value) => value!.toJson();

  static MapInfoAssets assetsFromJson(value) => MapInfoAssets.fromJson(value);

  static Offset ListAsOffset(List value) => Offset(double.parse(value.first.toString()), double.parse(value.last.toString()));

  static List OffsetAsList(Offset value) => [value.dx, value.dy];

  static List<Map<String, dynamic>> childsToJson(List<MapInfoAssets> list) => list.map((e) => e.toJson()).toList();

  static Map<Factions, MapInfoFactionInfo> factionsFromJson(Map factions) {
    Map<Factions, MapInfoFactionInfo> map = {};
    factions.forEach((key, value) {
      map.addAll({Factions.parse(key): MapInfoFactionInfo.fromJson(value)});
    });
    return map;
  }

  static List markerToJson(List<MapInfoMarkerItem>? value) => value!.map((e) => e.toJson()).toList();

  static List<MapInfoMarkerItem>? markerFromJson(List value) => value.map((e) => MapInfoMarkerItem.fromJson(e)).toList();

  factory MapInfo.fromJson(Map<String, dynamic> json) => _$MapInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MapInfoToJson(this);
}

/// 地图阵营位置
enum MapInfoFactionInfoDirection {
  Top(value: "Top"),
  Left(value: "Left"),
  Right(value: "Right"),
  Bottom(value: "Bottom");

  final String value;

  const MapInfoFactionInfoDirection({
    required this.value,
  });
}

/// 地图阵营信息
@JsonSerializable()
class MapInfoFactionInfo {
  // 火炮位置
  @JsonKey(toJson: gunToJson)
  List<Gun> gunPosition = [];

  // HQ点
  @JsonKey(toJson: pointsToJson, fromJson: pointsFromJson)
  List<Offset> points = [];

  // 位于地方方向
  @JsonKey(toJson: MapInfoFactionInfoDirectionToJson)
  MapInfoFactionInfoDirection direction;

  MapInfoFactionInfo({
    this.gunPosition = const [],
    this.points = const [],
    this.direction = MapInfoFactionInfoDirection.Left,
  });

  static List gunToJson(List<Gun> value) => value.map((e) => e.toJson()).toList();

  static List<dynamic> pointsToJson(List<Offset> value) {
    List list = [];
    for (var i in value) {
      list.add([i.dx, i.dy]);
    }
    return list;
  }

  static List<Offset> pointsFromJson(List value) {
    List<Offset> list = [];
    for (var i in value) {
      list.add(Offset(double.parse(i.first.toString()), double.parse(i.last.toString())));
    }
    return list;
  }

  static String MapInfoFactionInfoDirectionToJson(MapInfoFactionInfoDirection direction) => direction.value;

  factory MapInfoFactionInfo.fromJson(Map<String, dynamic> json) => _$MapInfoFactionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MapInfoFactionInfoToJson(this);
}

/// 地图标点
@JsonSerializable()
class MapInfoMarkerItem {
  // 标点名称
  final String? name;

  // 图标
  final MapIconType iconType;

  // 图片地址(可选)
  late String? iconPath;

  // 坐标
  @JsonKey(toJson: pointsToJson, fromJson: pointsFromJson)
  late List<MarkerPointItem> points = [];

  MapInfoMarkerItem({
    this.name = "none",
    required this.iconType,
    this.iconPath = "",
    this.points = const [],
  });

  static List pointsToJson(List<MarkerPointItem> value) => value.map((e) => e.toJson()).toList();

  static List<MarkerPointItem> pointsFromJson(List value) => value.map((e) => MarkerPointItem.fromJson(e)).toList();

  factory MapInfoMarkerItem.fromJson(Map<String, dynamic> json) => _$MapInfoMarkerItemFromJson(json);

  Map<String, dynamic> toJson() => _$MapInfoMarkerItemToJson(this);
}

/// 图标标点
/// 类似[MapInfoMarkerItem], 独立，额外提供x，y
class MapInfoMarkerItem_Fll {
  // 上级名称
  final String upLevelName;

  // 标点名称
  final String name;

  // 图标
  final MapIconType iconType;

  // 图片地址(可选)
  late String? iconPath;

  final double x;
  final double y;

  MapInfoMarkerItem_Fll({
    this.upLevelName = "none",
    this.name = "none",
    required this.iconType,
    this.iconPath = "",
    this.x = -1,
    this.y = -1,
  });
}

@JsonSerializable()
class MarkerPointItem {
  // id
  @JsonKey(includeToJson: false, includeFromJson: false)
  late String? id;

  // 名称
  late String name;

  // x轴-坐标
  double x;

  // y轴-坐标
  double y;

  MarkerPointItem({
    this.name = "none",
    this.x = .0,
    this.y = -.0,
    this.id,
  }) {
    id = const Uuid().v5(Uuid.NAMESPACE_NIL, "MarkerPointItem-$id-$name-$x,$y");
  }

  factory MarkerPointItem.fromJson(Map<String, dynamic> json) => _$MarkerPointItemFromJson(json);

  Map<String, dynamic> toJson() => _$MarkerPointItemToJson(this);
}

/// 资源
@JsonSerializable()
class MapInfoAssets {
  // 下标排序
  @JsonKey(includeToJson: false, includeFromJson: false)
  int index;

  // 类型
  @JsonKey(includeToJson: false, includeFromJson: false)
  MapIconType type;

  // 网络
  @JsonKey(defaultValue: "")
  String? network;

  // 本地
  @JsonKey(defaultValue: "")
  String? local;

  MapInfoAssets({
    this.index = 0,
    this.type = MapIconType.None,
    this.network,
    this.local,
  });

  String get url => (network ?? local) ?? "";

  get image => network != null ? NetworkImage(url) : AssetImage(url);

  factory MapInfoAssets.fromJson(Map<String, dynamic> json) => _$MapInfoAssetsFromJson(json);

  Map<String, dynamic> toJson() => _$MapInfoAssetsToJson(this);
}
