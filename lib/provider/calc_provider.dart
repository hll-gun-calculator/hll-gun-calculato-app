import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/index.dart';
import '../utils/index.dart';

class CalcProvider with ChangeNotifier {
  Storage storage = Storage();

  String packageName = "calc";

  final List<Map> _localCalcPath = [
    {"name": "internal-calc", "path": "assets/json/fun-internal-calc.json"},
  ];

  // 内置配置列表
  late final List<CalculatingFunction> _internalCalcList = [];

  // 自定义配置列表
  late final List<CalculatingFunction> _customCalcList = [];

  // 列表 自定义+内置
  List<CalculatingFunction> get calcList => [..._internalCalcList, ..._customCalcList];

  CalculatingFunction _defaultCalculatingFunction = CalculatingFunction(name: "internal-calc");

  // 默认计算函数实例
  CalculatingFunction get defaultCalculatingFunction => calcList.isEmpty ? _defaultCalculatingFunction : calcList[0];

  late ValueNotifier<String> _currentCalculatingFunctionName = ValueNotifier<String>(defaultCalculatingFunction.name);

  // 当前函数监听器
  ValueNotifier<String> get currentCalculatingFunctionNameValueNotifier => _currentCalculatingFunctionName;

  // 当前哟路虎所选计算函数实例
  CalculatingFunction get currentCalculatingFunction {
    if (calcList.where((i) => i.name == _currentCalculatingFunctionName.value).isEmpty) return defaultCalculatingFunction;
    return calcList.where((i) => i.name == _currentCalculatingFunctionName.value).first;
  }

  // 当前用户所选计算函数名称
  String get currentCalculatingFunctionName => _currentCalculatingFunctionName.value;

  // 设置选择计算函数
  set currentCalculatingFunctionName(String value) {
    _currentCalculatingFunctionName.value = value;
    _defaultCalculatingFunction = calcList.where((element) => element.name == value).first;
    notifyListeners();
  }

  Future init() async {
    await _readLocalInstalledCalc();
    await _readLocalCustomCalc();

    notifyListeners();
    return true;
  }

  /// 保存
  void _save() {
    storage.set(packageName, value: {
      "custom": _customCalcList.map((e) => e.toJson()).toList(),
      "currentCalculatingFunctionName": currentCalculatingFunction.name,
    });
  }

  /// 读取本地内置配置
  Future _readLocalInstalledCalc() async {
    for (var i in _localCalcPath) {
      dynamic d = await rootBundle.loadString(i["path"]);
      CalculatingFunction calculatingFunction = CalculatingFunction.fromJson(jsonDecode(d));
      calculatingFunction.type = CalculatingFunctionType.Internal;
      _internalCalcList.add(calculatingFunction);
    }
    return true;
  }

  /// 读取本地自定义配置
  Future _readLocalCustomCalc() async {
    StorageData calcLocalData = await storage.get(packageName);
    List<CalculatingFunction> calculatingFunctions = [];

    if (calcLocalData.code == 0) {

      for (var i in (calcLocalData.value["custom"] as List)) {
        CalculatingFunction calculatingFunction = CalculatingFunction.fromJson(i);
        calculatingFunction.type = CalculatingFunctionType.Custom;
        calculatingFunctions.add(calculatingFunction);
      }

      _customCalcList.addAll(calculatingFunctions);
      _currentCalculatingFunctionName.value = calcLocalData.value["currentCalculatingFunctionName"] ?? _defaultCalculatingFunction.name;
    }

    return true;
  }

  /// 从互联网添加配置
  Future cloudNetworkLoadCalc(String path) async {
    Response result = await Http.request(path, method: Http.GET, httpDioType: HttpDioType.none);
    return result;
  }

  /// 排序
  CalcProvider sort() {
    calcList.sort((a, b) => a.creationTime.millisecondsSinceEpoch - b.creationTime.millisecondsSinceEpoch);
    return this;
  }

  /// 删除本地自定义
  void deleteLocalCustom(String name) {
    _customCalcList.removeWhere((i) => i.name == name && i.type == CalculatingFunctionType.Custom);
    _currentCalculatingFunctionName.value = calcList.first.name;
    _save();
    notifyListeners();
  }

  /// 更新配置
  void updataCustomConfig (String id, CalculatingFunction data) {
    if (id.isEmpty && _customCalcList.isEmpty) return;
    int index = _customCalcList.indexWhere((i) => i.id == id);
    if (index < 0) return;
    _customCalcList[index] = data;
    _save();
    notifyListeners();
  }

  /// 添加配置
  void addCustomConfig({
    required String title,
    required String data,
  }) {
    dynamic json = jsonDecode(data);
    CalculatingFunction calculatingFunction = CalculatingFunction.fromJson(json);
    calculatingFunction.type = CalculatingFunctionType.Custom;
    calculatingFunction.name = title;
    _customCalcList.add(calculatingFunction);

    _save();

    notifyListeners();
  }

  /// 视图选择保存
  void selectCalculatingFunction(String name) {
    if (name.isEmpty) return;
    _currentCalculatingFunctionName.value = name;
    _save();
    notifyListeners();
  }
}
