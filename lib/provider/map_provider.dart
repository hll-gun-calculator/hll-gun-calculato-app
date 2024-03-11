import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app.dart';
import '../data/index.dart';

class MapProvider with ChangeNotifier {
  List _localPath = [
    {"name": "internal", "path": "assets/json/map-internal.json"}
  ];

  // 内置
  List<MapCompilation> _internalPath = [];

  // 自定义
  List<MapCompilation> _customPath = [];

  List<MapCompilation> get list => [..._internalPath, ..._customPath];

  // 默认地图集合名称
  String _defaultMapCompilationName = "internal";

  // 当前地图集合实例
  MapCompilation get currentMapCompilation {
    return list.where((i) => i.name == currentMapCompilationName).first;
  }

  String? _currentMapCompilationName;

  // 当前地图集合名称
  String get currentMapCompilationName => _currentMapCompilationName == null ? _defaultMapCompilationName : _currentMapCompilationName!;

  set currentMapCompilationName(String name) {
    _currentMapCompilationName = name;
    notifyListeners();
  }

  String? _currentMapInfoName;

  // 当前选择地图
  MapInfo get currentMapInfo => _currentMapInfoName == null ? currentMapCompilation.data.first : currentMapCompilation.data.where((i) => i.name == _currentMapInfoName).first;

  // 设置选择地图
  set currentMapInfo(MapInfo mapInfo) {
    _currentMapInfoName = mapInfo.name;
  }

  // 是否有地图信息
  bool get hasMapInfo => false;

  // 当前选择火炮
  late Gun _currentMapGun = currentMapInfo.gunPosition.first;

  Gun get currentMapGun => _currentMapGun;

  set currentMapGun(Gun gun) {
    _currentMapGun = gun;
    notifyListeners();
  }

  init() {
    _readLocal();
    notifyListeners();
  }

  // 从本地读取自定义
  Future _readLocal() async {
    for (var i in _localPath) {
      dynamic d = await rootBundle.loadString(i["path"]);
      MapCompilation mapCompilation = MapCompilation.fromJson(jsonDecode(d));
      _internalPath.add(mapCompilation);
    }
    return true;
  }
}

/// 地图包管理
class MapPackage with ChangeNotifier {}

/// 控制当前地图
class MapWidget with ChangeNotifier {
  init() {}
}
