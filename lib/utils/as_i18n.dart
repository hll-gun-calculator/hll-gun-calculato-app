import 'package:flutter/cupertino.dart';

import '../constants/app.dart';

class I18nUtil {
  String as(BuildContext context, dynamic data) {
    String string = data.toString();
    if (data is Map) {
      string = data[App.provider.ofLang(context).currentLang];
    }
    if (data is String && data.isEmpty) string = "";
    return string;
  }
}
