import 'package:flutter/material.dart';

import '/data/HomeApp.dart';
import '/utils/index.dart';
import '/pages/index/calc.dart';
import '/pages/index/gunComparisonTable.dart';
import '/pages/index/landingTimer.dart';
import '/pages/index/map.dart';

class HomeAppProvider with ChangeNotifier {
  String PACKAGENAME = "home_app";

  Storage _storage = Storage();

  // 应用上限以及下限
  final int appMaxLength = 4;
  final int appMinLength = 2;

  // 默认
  final List<HomeAppData> _allPanelLists = [
    HomeAppData(
      name: "gunCalc",
      icon: const Icon(Icons.calculate_outlined, size: 30),
      activeIcon: const Icon(Icons.calculate, size: 30),
      widget: const calcPage(),
      type: HomeAppType.Calc,
    ),
    HomeAppData(
      name: "map",
      icon: const Icon(Icons.map_outlined, size: 30),
      activeIcon: const Icon(Icons.map, size: 30),
      widget: const MapPage(),
      type: HomeAppType.Map,
      isShowAppBar: false,
    ),
    HomeAppData(
      name: "landingTimer",
      icon: const Icon(Icons.timer_outlined, size: 30),
      activeIcon: const Icon(Icons.timer, size: 30),
      widget: const LandingTimerPage(),
      type: HomeAppType.LandingTimer,
    ),
    HomeAppData(
      name: "gunComparisonTable",
      icon: const Icon(Icons.table_chart_outlined, size: 30),
      activeIcon: const Icon(Icons.table_chart, size: 30),
      widget: const GunComparisonTablePage(),
      type: HomeAppType.GunComparisonTable,
    ),
  ];

  // 已选择
  // 至少 [appMinLength].length
  late final ValueNotifier<List<HomeAppData>> _panelLists = ValueNotifier([
    _allPanelLists[0],
    _allPanelLists[2],
  ]);

  // 未激活
  late final ValueNotifier<List<HomeAppData>> _unactivatedPandeLists = ValueNotifier([
    _allPanelLists[1],
    _allPanelLists[3],
  ]);

  Future init() async {
    _readLocalStorage();
    notifyListeners();
    return true;
  }

  List<Widget> get widgets => _panelLists.value.map((e) => e.widget).toList();

  List<HomeAppData> get activeList => _panelLists.value;

  set activeList(List<HomeAppData> list) {
    _panelLists.value = list;
    _saveLocalStorage();
    notifyListeners();
  }

  List<HomeAppData> get unactivatedList => _unactivatedPandeLists.value;

  /// 是否激活列表有此item
  bool hasItem(String name) {
    return activeList.where((element) => element.name == name).isNotEmpty;
  }

  HomeAppData _stringAsHomeAppData(String name) {
    return _allPanelLists.where((homeApp) => homeApp.name == name).first;
  }

  /// 读取本地配置
  void _readLocalStorage() async {
    StorageData homeAppData = await _storage.get(PACKAGENAME);
    if (homeAppData.code == 0) {
      _panelLists.value = [];
      _unactivatedPandeLists.value = [];

      homeAppData.value.forEach((i) {
        _panelLists.value.add(_stringAsHomeAppData(i));
      });

      _unactivatedPandeLists.value = _allPanelLists.toSet().difference(_panelLists.value.toSet()).toList();
    }
  }

  /// 保存配置
  void _saveLocalStorage() {
    List value = _panelLists.value.map((e) => e.name).toList();
    _storage.set(PACKAGENAME, value: value);
  }

  /// 添加
  void add(HomeAppData homeAppData) {
    if (activeList.length > appMaxLength) return;

    _unactivatedPandeLists.value.remove(homeAppData);
    _panelLists.value.add(homeAppData);
    _saveLocalStorage();
    notifyListeners();
  }

  /// 移除
  void remove(HomeAppData homeAppData) {
    if (activeList.length < appMinLength) return;

    _panelLists.value.remove(homeAppData);
    _unactivatedPandeLists.value.add(homeAppData);
    _saveLocalStorage();
    notifyListeners();
  }
}
