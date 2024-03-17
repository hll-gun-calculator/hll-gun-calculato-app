/// 状态管理 工具包
import 'package:provider/provider.dart';

import '/provider/home_app_provider.dart';
import '/provider/history_provider.dart';
import '/provider/gun_timer_provider.dart';
import '/provider/map_provider.dart';
import '/provider/package_provider.dart';
import '/provider/calc_provider.dart';
import '/provider/theme_provider.dart';
import '/provider/collect_provider.dart';
import '/provider/translation_provider.dart';

class ProviderUtil {
  // 应用
  PackageProvider ofApp(context) {
    return Provider.of<PackageProvider>(context, listen: false);
  }

  // 火炮定时器
  GunTimerProvider ofGunTimer(context) {
    return Provider.of<GunTimerProvider>(context, listen: false);
  }

  // 国际化
  TranslationProvider ofLang(context) {
    return Provider.of<TranslationProvider>(context, listen: false);
  }

  // 地图
  MapProvider ofMap(context) {
    return Provider.of<MapProvider>(context, listen: false);
  }

  // 计算
  CalcProvider ofCalc(context) {
    return Provider.of<CalcProvider>(context, listen: false);
  }

  // 主题
  ThemeProvider ofTheme(context) {
    return Provider.of<ThemeProvider>(context, listen: false);
  }

  // 收藏
  CollectProvider ofCollect(context) {
    return Provider.of<CollectProvider>(context, listen: false);
  }

  // 历史
  HistoryProvider ofHistory(context) {
    return Provider.of<HistoryProvider>(context, listen: false);
  }

  // 首页面板
  HomeAppProvider ofHomeApp (context) {
    return Provider.of<HomeAppProvider>(context, listen: false);
  }
}
