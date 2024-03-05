/// 全局接口配置
import '../data/Url.dart';

enum Env { PROD, DEV }

class Config {
  static Env env = Env.DEV;
  static final List _envStringNames = ["production", "development"];
  static String _envCurrentStringName = "";
  static Map<String, BaseUrl> apis = {};

  /// 当前环境名称
  /// [_envStringNames] 所有
  static String get envCurrentName => _envCurrentStringName;

  /// 基础请求
  static Map<String, BaseUrl> get apiHost {
    Map<String, BaseUrl> d = {"none": BaseUrl()};
    d.addAll(apis);
    return d;
  }

  Config.dev({required Map<String, BaseUrl> api}) {
    Config.apis.addAll(api);
    Config.env = Env.DEV;
    Config._envCurrentStringName = _envStringNames[Config.env.index];
  }

  // <String, BaseUrl>
  Config.prod({required Map<String, BaseUrl> api}) {
    Config.apis.addAll(api);
    Config.env = Env.PROD;
    Config._envCurrentStringName = _envStringNames[Config.env.index];
  }
}
