import 'package:flutter/cupertino.dart';

import '../constants/app.dart';
import '../provider/translation_provider.dart';

class I18nUtil {
  String as(BuildContext context, dynamic data) {
    String string = "";
    if (data is String && data != null) {
      string = data;
    } else if (data is Map && data != null) {
      TranslationProvider translationProvider = App.provider.ofLang(context);
      String currentLang = translationProvider.currentLang;
      string = data.containsKey(currentLang) ? data[currentLang] : data[translationProvider.defaultLang];
    } else {
      string = data.toString();
    }
    return string;
  }
}
