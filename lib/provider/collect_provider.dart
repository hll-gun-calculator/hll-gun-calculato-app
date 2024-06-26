import 'package:flutter/material.dart';

import '../data/index.dart';
import '../utils/index.dart';

class CollectProvider with ChangeNotifier {
  Storage storage = Storage();

  String packageName = "collect";

  List<CollectItemData> _list = [];

  List<CollectItemData> get list => _list;

  Future init() async {
    await _readLocal();
    notifyListeners();
    return true;
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
    print(_list);
    return _list.where((element) => element.id == id).isNotEmpty;
  }

  // 预选
  List<CollectItemData> primarySelection(String value, {length = 3}) {
    if (value.isEmpty) return [];
    return _list.where((i) => i.inputValue.contains(value)).toList();
  }

  /// 查询是否有重复
  bool hasItem({
    Factions inputFactions = Factions.None,
    String inputValue = "",
    String title = "",
    String remark = "",
    String id = "",
  }) {
    return _list.where((i) {
      if (i.inputValue == inputValue && i.inputFactions == inputFactions) {
        return true;
      }

      if (title.isNotEmpty) {
        return i.title.contains(title);
      }
      if (remark.isNotEmpty) {
        return i.remark.indexOf(remark) >= 0;
      }
      if (id.isNotEmpty) {
        return i.id == id;
      }
      return true;
    }).isNotEmpty;
  }

  /// 添加收藏
  void add(dynamic i, String title, {String remark = "", String id = ""}) {
    if (i is! CalcResult && i is! MapGunResult) return;

    CollectItemData collectItemData = CollectItemData();
    collectItemData.as(i);

    collectItemData.title = title;
    if (remark.isNotEmpty) collectItemData.remark = remark;
    if (id.isNotEmpty) collectItemData.id = id;

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

  /// 排序
  CollectProvider sort() {
    _list.sort((a, b) => a.creationTime!.millisecondsSinceEpoch - b.creationTime!.millisecondsSinceEpoch);
    return this;
  }
}
