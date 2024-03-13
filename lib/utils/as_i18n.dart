import 'package:flutter/cupertino.dart';

import '../constants/app.dart';

class I18nUtil {
  String as(BuildContext context, dynamic data) {
    String string = "";
    if (data is Map) {
      string = data[App.provider.ofLang(context).currentLang];
    }
    return string;
  }
}
