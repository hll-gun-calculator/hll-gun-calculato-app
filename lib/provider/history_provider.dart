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

  /// 添加
  void add (CalcResult result) {
    CalcHistoryItemData calcHistoryItemData = CalcHistoryItemData();
    calcHistoryItemData.as(result);
    list.add(calcHistoryItemData);
    notifyListeners();
  }
}