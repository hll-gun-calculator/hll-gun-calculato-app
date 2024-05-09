/// 账户持久管理

import "storage.dart";

class StorageConfig extends Storage {
  String PACKAGENAME = 'configuration';

  /// 更新本地配置
  updateAttr(String key, dynamic value) async {
    StorageData userData = await get(PACKAGENAME);
    Map data = userData.value ??= {};

    data[key] = value;
    super.set(PACKAGENAME, value: data);
  }

  /// 取得配置值
  getAttr(String key, {dynamic defaultValue}) async {
    StorageData userData = await get(PACKAGENAME);
    Map data = userData.value ??= {};

    if (userData.code != 0) return defaultValue ??= false;
    // * The configuration is usually of type bool
    return Map.from(data).containsKey(key) ? data[key] : defaultValue ??= false;
  }
}
