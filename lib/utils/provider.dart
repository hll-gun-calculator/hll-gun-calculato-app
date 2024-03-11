/// 状态管理 工具包
import 'package:provider/provider.dart';

import '../provider/map_provider.dart';
import '../provider/package_provider.dart';
import '/provider/calc_provider.dart';
import '/provider/theme_provider.dart';
import '/provider/collect_provider.dart';
import '/provider/translation_provider.dart';

class ProviderUtil {
  PackageProvider ofApp(context) {
    return Provider.of<PackageProvider>(context, listen: false);
  }

  // 国际化
  TranslationProvider ofLang(context) {
    return Provider.of<TranslationProvider>(context, listen: false);
  }

  MapProvider ofMap(context) {
    return Provider.of<MapProvider>(context, listen: false);
  }

  CalcProvider ofCalc(context) {
    return Provider.of<CalcProvider>(context, listen: false);
  }

  ThemeProvider ofTheme(context) {
    return Provider.of<ThemeProvider>(context, listen: false);
  }

  CollectProvider ofCollect(context) {
    return Provider.of<CollectProvider>(context, listen: false);
  }
}
