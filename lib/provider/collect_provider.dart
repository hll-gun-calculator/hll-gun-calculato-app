import 'package:flutter/material.dart';

import '../data/index.dart';
import '../utils/index.dart';

class CollectProvider with ChangeNotifier {
  Storage storage = Storage();

  String packageName = "collect";

  List<CollectItemData> _list = [];

  List<CollectItemData> get list => _list;

  init() async {
    await _readLocal();
    notifyListeners();
  }

  _readLocal() async {
    StorageData data = await storage.get(packageName);
    if (data.code == 0) {
      List<CollectItemData> l = [];
      data.value.forEach((i) {
        CollectItemData collectItemData = CollectItemData.fromJson(i);
        l.add(collectItemData);
      });
      _list.addAll(l);
    }
  }

  _save() {
    List collectItemList = _list.map((e) => e.toJson()).toList();
    storage.set(packageName, value: collectItemList);
  }

  bool hasAsId(String id) {
    if (id.isEmpty) return false;
    return _list.where((element) => element.id == id).isNotEmpty;
  }

  // 预选
  List<CollectItemData> primarySelection (String value, {length = 3}) {
    if (value.isEmpty) return [];
    return _list.where((i) => i.inputValue.contains(value)).toList();
  }

  /// 添加收藏
  add(CalcResult i, String title, {String remark = ""}) {
    CollectItemData collectItemData = CollectItemData();
    collectItemData.as(i);
    collectItemData.title = title;
    collectItemData.remark = remark;
    _list.add(collectItemData);
    _save();
    notifyListeners();
  }

  /// 以下标删除
  deleteAsIndex(int index) {
    _list.removeAt(index);
    _save();
    notifyListeners();
  }

  /// 以id删除
  deleteAsId(String id) {
    _list.removeWhere((element) => element.id == id);
    _save();
    notifyListeners();
  }
}
