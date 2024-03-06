import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/index.dart';
import '../utils/index.dart';

class CalcProvider with ChangeNotifier {
  Storage storage = Storage();

  String packageName = "calc";

  final List<Map> _localCalcPath = [
    {"name": "internal-calc", "path": "assets/json/internal-calc.json"},
    {"name": "easyarty", "path": "assets/json/easyarty.json"}
  ];

  // 内置配置列表
  late final List<CalculatingFunction> _internalCalcList = [];

  // 自定义配置列表
  late final List<CalculatingFunction> _customCalcList = [];

  // 列表 自定义+内置
  List<CalculatingFunction> get calcList {
    print(_customCalcList);
    return [..._internalCalcList, ..._customCalcList];
  }

  // 默认计算函数实例
  CalculatingFunction get defaultCalculatingFunction => calcList.isEmpty ? CalculatingFunction(name: "internal-calc") : calcList[0];

  late String _currentCalculatingFunctionName = defaultCalculatingFunction.name;

  // 当前哟路虎所选计算函数实例
  CalculatingFunction get currentCalculatingFunction {
    if (calcList.where((i) => i.name == _currentCalculatingFunctionName).isEmpty) return defaultCalculatingFunction;
    return calcList.where((i) => i.name == _currentCalculatingFunctionName).first;
  }

  // 当前用户所选计算函数名称
  String get currentCalculatingFunctionName => _currentCalculatingFunctionName;

  // 设置选择计算函数
  set currentCalculatingFunctionName(String value) {
    _currentCalculatingFunctionName = value;
  }

  init() async {
    await _readLocalInstalledCalc();
    await _readLocalCustomCalc();

    notifyListeners();
  }

  /// 保存
  void _save() {
    storage.set(packageName, value: {
      "custom": _customCalcList.where((i) => i.isCustom).toList(),
      "currentCalculatingFunctionName": currentCalculatingFunction.name,
    });
  }

  /// 读取本地内置配置
  Future _readLocalInstalledCalc() async {
    for (var i in _localCalcPath) {
      dynamic d = await rootBundle.loadString(i["path"]);
      CalculatingFunction calculatingFunction = CalculatingFunction.fromJson(jsonDecode(d));
      calculatingFunction.isCustom = false;
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
        calculatingFunction.isCustom = true;
        calculatingFunctions.add(calculatingFunction);
      }

      _customCalcList.addAll(calculatingFunctions);
      _currentCalculatingFunctionName = calcLocalData.value["currentCalculatingFunctionName"];
    }

    return true;
  }

  /// 从互联网添加配置
  Future _cloudNetworkLoadCalc(String path) async {
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
    if (name.isEmpty) return;

    _customCalcList.removeWhere((i) => i.name == name && i.isCustom);

    _save();
    notifyListeners();
  }

  /// 从网络添加
  Future addNetworkCustom({
    required String title,
    required String path,
  }) async {
    Response result = await _cloudNetworkLoadCalc(path);

    // todo 校验json
    if (result.data != null) {
      dynamic json = jsonDecode(result.data);
      CalculatingFunction calculatingFunction = CalculatingFunction.fromJson(json);
      calculatingFunction.isCustom = true;
      _customCalcList.add(calculatingFunction);

      _save();
    }

    notifyListeners();
    return result;
  }

  /// 从本地添加
  void addLocalCustom({
    required String title,
    required String data,
  }) {
    CalculatingFunction calculatingFunction = CalculatingFunction.fromJson(jsonDecode(data));
    calculatingFunction.isCustom = true;
    _customCalcList.add(calculatingFunction);

    _save();

    notifyListeners();
  }

  /// 视图选择保存
  void selectCalculatingFunction(String name) {
    if (name.isEmpty) return;
    _currentCalculatingFunctionName = name;
    _save();
    notifyListeners();
  }
}
