import 'package:json_annotation/json_annotation.dart';

import 'MapToI18n.dart';
import 'index.dart';

part 'MapCompilation.g.dart';

/// 地图合集
@JsonSerializable()
class MapCompilation {
  @StringOrMapConverter()
  String name;

  @StringOrMapConverter()
  dynamic description;

  String author;

  String version;

  List<MapInfo> data;

  MapCompilation({
    this.name = "none",
    this.description = "",
    this.author = "none",
    this.version = "0.0.1",
    this.data = const [],
  });

  factory MapCompilation.fromJson(Map<String, dynamic> json) => _$MapCompilationFromJson(json);

  Map<String, dynamic> toJson() => _$MapCompilationToJson(this);
}
