import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/index.dart';
import '../utils/index.dart';

class CalcProvider with ChangeNotifier {
  Storage storage = Storage();

  String packageName = "calc";

  List<String> localCalcPath = ["assets/json/internal-calc.json", "assets/json/easyarty.json"];

  List<CalculatingFunction> calcList = [];

  // 默认
  CalculatingFunction get defaultCalculatingFunction => calcList.isEmpty ? CalculatingFunction(name: "internal-calc") : calcList[0];

  // 用户所选
  late String _currentCalculatingFunction = defaultCalculatingFunction.name;

  CalculatingFunction get currentCalculatingFunction {
    if (calcList.where((i) => i.name == _currentCalculatingFunction).isEmpty) return defaultCalculatingFunction;
    return calcList.where((i) => i.name == _currentCalculatingFunction).first;
  }

  String get currentCalculatingFunctionName => _currentCalculatingFunction;

  set currentCalculatingFunctionName(String value) {
    _currentCalculatingFunction = value;
  }

  init() async {
    await _readLocalCalc();
    await _readLocalCustomCalc();
    notifyListeners();
  }

  /// 读取本地内置配置
  Future _readLocalCalc() async {
    for (var i in localCalcPath) {
      dynamic d = await rootBundle.loadString(i);
      CalculatingFunction calculatingFunction = CalculatingFunction.fromJson(jsonDecode(d));
      calcList.add(calculatingFunction);
    }
    return true;
  }

  /// 读取本地自定义配置
  Future _readLocalCustomCalc() async {
    StorageData calcLocalData = await storage.get(packageName);
    if (calcLocalData.code == 0) {
      // calcList.addAll(calcLocalData.value["custom"]);
    }
    return true;
  }

  /// 从互联网添加配置
  void _cloudNetworkLoadCalc(String path) async {
    Response result = await Http.request(path);

    if (result.statusCode == 200 && result.extra["c"] == "json") {
      // todo 校验是否json
      calcList.add(result.data);
    }
  }

  /// 从网络添加
  void addNetworkCustom({
    required String title,
    required String path,
  }) {
    if (title.isEmpty || path.isEmpty) return;

    List saveCalcList = List.from(calcList);
    saveCalcList.where((i) => i["name"] != "internal-calc");

    _cloudNetworkLoadCalc(path);

    storage.set(packageName, value: {"custom": saveCalcList, "currentCalculatingFunctionName": currentCalculatingFunction.name});

    notifyListeners();
  }

  /// 从本地添加
  void addLocalCustom({
    required String title,
    required String path,
  }) {}

  /// 视图选择保存
  void selectCalculatingFunction(String name) {
    if (name.isEmpty) return;
    _currentCalculatingFunction = name;
    notifyListeners();
  }
}
