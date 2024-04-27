import 'package:hll_gun_calculator/data/UpdataFunction.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'MapToI18n.dart';
import 'UpdataFunctionBaseClass.dart';
import 'index.dart';

part 'MapCompilation.g.dart';

/// 地图合集
@JsonSerializable()
class MapCompilation {
  late String id;

  @StringOrMapConverter()
  String name;

  @StringOrMapConverter()
  dynamic description;

  String author;

  String version;

  @JsonKey(toJson: updataFunctionToJson, fromJson: updataFunctionFromJson)
  List<UpdataFunction> updataFunction;

  @JsonKey(toJson: dataToJson)
  List<MapInfo> data;

  MapCompilationType type;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool _isEmpty = false;

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
    if (id.isNotEmpty) {
      id = createId;
    }
  }

  bool get empty => _isEmpty;

  String get createId => const Uuid().v5(
    Uuid.NAMESPACE_NIL,
    "MapCompilation-$name-$author-$version",
  );

  static List dataToJson(List<MapInfo> list) => list.map((e) => e.toJson()).toList();

  static List updataFunctionToJson (List<UpdataFunction> values) => values.map((e) => e.toJson()).toList();

  static List<UpdataFunction> updataFunctionFromJson (List values) => values.map((e) => UpdataFunction.fromJson(e)).toList();

  factory MapCompilation.empty({String? id}) => MapCompilation(id: id!).._isEmpty = true;

  factory MapCompilation.fromJson(Map<String, dynamic> json) => _$MapCompilationFromJson(json);

  Map<String, dynamic> toJson() => _$MapCompilationToJson(this);
}

enum MapCompilationType { None, Custom }
