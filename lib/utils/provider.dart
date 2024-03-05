/// 状态管理 工具包

import 'package:hll_emplacement_calculator/provider/calc_provider.dart';
import 'package:hll_emplacement_calculator/provider/theme_provider.dart';
import 'package:provider/provider.dart';

import '../provider/collect_provider.dart';
import '../provider/translation_provider.dart';

class ProviderUtil {
  // 国际化
  TranslationProvider ofLang(context) {
    return Provider.of<TranslationProvider>(context, listen: false);
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
