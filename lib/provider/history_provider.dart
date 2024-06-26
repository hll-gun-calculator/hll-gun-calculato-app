import 'package:flutter/material.dart';

import '../data/index.dart';
import '../utils/index.dart';

class HistoryProvider with ChangeNotifier {
  // CalcList calcList = CalcList();

  Storage storage = Storage();

  String packageName = "calcHistory";

  List<CalcHistoryItemData> list = [];

  init () {
    notifyListeners();
  }

  /// 排序
  HistoryProvider sort () {
    list.sort((a, b) => a.creationTime!.millisecondsSinceEpoch + b.creationTime!.millisecondsSinceEpoch);
    return this;
  }

  /// 擦除
  void clean () {
    list.clear();
    notifyListeners();
  }

  /// 添加
  void add (CalcResult result) {
    CalcHistoryItemData calcHistoryItemData = CalcHistoryItemData();
    calcHistoryItemData.as(result);
    list.add(calcHistoryItemData);
    notifyListeners();
  }

  /// 删除
  void delete (CalcResult result) {
    list.remove(result);
    notifyListeners();
  }
}