import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hll_gun_calculator/constants/api.dart';

import '../data/index.dart';
import '../utils/index.dart';

class MapProvider with ChangeNotifier {
  String PACKAGENAME = "map";

  final Storage _storage = Storage();

  final List _localPath = [
    {"name": "internal", "path": "assets/json/map-internal.json"}
  ];

  // 内置
  final List<MapCompilation> _internalPath = [];

  // 自定义
  late List<MapCompilation> _customPath = [];

  List<MapCompilation> get list => [..._internalPath, ..._customPath];

  // 默认地图集合名称
  final String _defaultMapCompilationName = "internal";

  // 是否空集合
  bool get hasMapCompilation => currentMapCompilation.name == "empty";

  // 获取当前地图集合实例
  // 也可以使用[currentMapCompilationName]，效果一致
  MapCompilation get currentMapCompilation => list.where((i) => i.name == currentMapCompilationName).first;

  // 设置当前地图集合实例
  set currentMapCompilation(MapCompilation mapCompilation) {
    _currentMapCompilationName = mapCompilation.name;
    _saveLocalStorage();
    notifyListeners();
  }

  String? _currentMapCompilationName;

  // 当前地图集合名称
  // 也可以使用[currentMapCompilation]，效果一致
  String get currentMapCompilationName => _currentMapCompilationName == null ? _defaultMapCompilationName : _currentMapCompilationName!;

  set currentMapCompilationName(String name) {
    _currentMapCompilationName = name;
    _saveLocalStorage();
    notifyListeners();
  }

  String? _currentMapInfoName;

  // 当前选择地图
  MapInfo get currentMapInfo => _currentMapInfoName == null ? currentMapCompilation.data.first : currentMapCompilation.data.where((i) => i.name == _currentMapInfoName).first;

  // 设置选择地图
  set currentMapInfo(MapInfo mapInfo) {
    _currentMapInfoName = mapInfo.name;
    if (mapInfo.gunPositions.isNotEmpty) _currentMapGun = mapInfo.gunPositions.first;
    notifyListeners();
  }

  // 是否有地图信息
  bool get hasMapInfo => currentMapCompilation != null;

  // 当前选择火炮
  late Gun _currentMapGun = currentMapInfo.gunPositions.first;

  Gun get currentMapGun => _currentMapGun;

  set currentMapGun(Gun gun) {
    _currentMapGun = gun;
    notifyListeners();
  }

  Future init() async {
    _readLocalFiles();
    _readLocalStorage();
    notifyListeners();
    return true;
  }

  /// 给当前选择的火炮添加计算结果
  void setCurrentMapGunResult(MapGunResult mapGunResult) {
    _currentMapGun.result = mapGunResult;
    notifyListeners();
  }

  /// 从本地读取保存数据
  Future _readLocalStorage() async {
    StorageData mapData = await _storage.get(PACKAGENAME);

    if (mapData.code == 0) {
      _currentMapCompilationName = mapData.value["currentMapCompilationName"];
      _customPath = mapData.value["list"].map<MapCompilation>((e) => MapCompilation.fromJson(e)).toList();
    }
  }

  /// 更新配置
  void updataCustomConfig (String id, MapCompilation data) {
    if (id.isEmpty) return;
    int index = _customPath.indexWhere((i) => i.id == id);
    _customPath[index] = data;
    _saveLocalStorage();
    notifyListeners();
  }

  /// 保存地图数据
  void _saveLocalStorage() {
    Map value = {
      "currentMapCompilationName": _currentMapCompilationName,
      "list": _customPath.map((e) => e.toJson()).toList(),
    };

    _storage.set(PACKAGENAME, value: value);
  }

  /// 删除合集
  void deleteMapCompilation(MapCompilation mapCompilation) {
    list.removeAt(list.indexWhere((element) => element.name == mapCompilation.name));
    _currentMapCompilationName = list.first.name;
    _saveLocalStorage();
    notifyListeners();
  }

  /// 添加自定义配置
  void addCustomConfig({required String title, required Map<String, dynamic> data}) {
    MapCompilation mapCompilation = MapCompilation.fromJson(data);
    mapCompilation.type = MapCompilationType.Custom;
    _customPath.add(mapCompilation);
    _saveLocalStorage();
    notifyListeners();
  }

  /// 从本地读取自定义
  Future _readLocalFiles() async {
    if (Config.env == Env.DEV) {
      _localPath.add({"name": "test-mattw", "path": "assets/json/map-mattw.json"});
    }

    for (var i in _localPath) {
      dynamic d = await rootBundle.loadString(i["path"]);
      MapCompilation mapCompilation = MapCompilation.fromJson(jsonDecode(d));
      mapCompilation.type = MapCompilationType.None;
      _internalPath.add(mapCompilation);
    }
    return true;
  }
}
