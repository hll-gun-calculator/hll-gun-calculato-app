import 'package:flutter/cupertino.dart';

import '../utils/index.dart';

// 程序国际化
class TranslationProvider with ChangeNotifier {
  Storage storage = Storage();

  // 包名
  String packageName = "language";

  // 语言字典列表
  List _listDictionaryFrom = [];

  // 语言配置列表
  // 如: { 'zh': {} }
  Map _list = {};

  // 默认语言
  String _default = "zh_CN";

  String get defaultLang => _default;

  // 当前语言
  // 如: [zh, en, jp ...]
  String _currentLang = "";

  // 获取当前语言
  String get currentLang => _currentLang.isEmpty ? _default : _currentLang;

  // 转换当前语言对应的本地文本
  // 如: zh_CN:中文简体、en_US:English
  String get currentToLocalLangName {
    if (_listDictionaryFrom.isEmpty) return _currentLang;
    Iterable i = _listDictionaryFrom.where((element) => element["fileName"] == _currentLang);
    return i.isNotEmpty ? i.first["label"] : _currentLang;
  }

  set currentLang(String value) {
    _currentLang = value;
    setLocalLang();
    notifyListeners();
  }

  // 初始化
  Future init() async {
    Map localLang = await getLocalLang();

    // if (_listDictionaryFrom.isEmpty && localLang.isEmpty) {
    //   await getNetworkLangListDictionary();
    //   await updateLocalLang();
    // }

    _currentLang = localLang["currentLang"] ?? defaultLang;
    notifyListeners();
  }

  // [Event]
  // 读取本地语言表
  Future<Map> getLocalLang() async {
    StorageData languageData = await storage.get(packageName);
    dynamic local = languageData.value;

    if (local != null) {
      return local;
    }

    return {};
  }

  // [Event]
  // 写入本地消息内容
  Future<bool> setLocalLang() async {
    Map data = {
      "currentLang": currentLang,
    };

    await storage.set(packageName, value: data);
    return true;
  }
}
