import 'package:hll_gun_calculator/data/UpdataFunction.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'MapToI18n.dart';
import 'index.dart';

part 'MapCompilation.g.dart';

/// 地图合集
@JsonSerializable()
class MapCompilation {
  @JsonKey(includeToJson: false, includeFromJson: false)
  String id;

  @StringOrMapConverter()
  String name;

  @StringOrMapConverter()
  dynamic description;

  String author;

  String version;

  List<UpdataFunction> updataFunction;

  @JsonKey(toJson: dataToJson)
  List<MapInfo> data;

  MapCompilationType type;

  MapCompilation({
    this.id = "",
    this.name = "none",
    this.description = "",
    this.author = "none",
    this.version = "0.0.1",
    this.updataFunction = const [],
    this.data = const [],
    this.type = MapCompilationType.None,
  }) {
    id = const Uuid().v5(
      Uuid.NAMESPACE_NIL,
      "MapCompilation-$name-$author-$version",
    );
  }

  static List dataToJson(List<MapInfo> list) => list.map((e) => e.toJson()).toList();

  factory MapCompilation.fromJson(Map<String, dynamic> json) => _$MapCompilationFromJson(json);

  Map<String, dynamic> toJson() => _$MapCompilationToJson(this);
}

enum MapCompilationType { None, Custom }
