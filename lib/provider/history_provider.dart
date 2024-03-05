import 'package:flutter/material.dart';

import '../data/index.dart';
import '../utils/index.dart';

class HistoryProvider with ChangeNotifier {
  CalcList calcList = CalcList();

  Storage storage = Storage();

  String packageName = "calcHistory";

  List<CalcResult> get list => calcList.list ?? [];

  init () {
    _readLocalHistory();
    notifyListeners();
  }

  void _readLocalHistory () async {
    StorageData calcHistoryData = await storage.get(packageName);

    if (calcHistoryData.code == 0) {
      // calcList.list.addAll(calcHistoryData.value);
    }
  }

  void add (CalcResult result) {
    calcList.list.add(result);
    notifyListeners();
  }

  void save () {

  }
}