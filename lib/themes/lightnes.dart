import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/index.dart';

class LightnesTheme extends AppBaseThemeItem {
  @override
  init() {}

  @override
  changeSystem() {
    SystemUiOverlayStyle systemUiOverlayStyle =  SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: const Color(0xff625648).withOpacity(.2),
      statusBarBrightness: Brightness.dark,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  @override
  get d => data;

  @override
  static dynamic data = AppThemeItem(
    name: "lightnes",
    isDefault: true,
    themeData: ThemeData.light(useMaterial3: true).copyWith(
      primaryColor: const Color(0xff625648),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xff625648),
        onPrimary: Color(0xffffffff),
        primaryContainer: Color(0xfffff7ee),
        onPrimaryContainer: Color(0xff001d31),
        secondary: Color(0xff575e71),
        onSecondary: Color(0xffffffff),
        secondaryContainer: Color(0xfffff7ee),
        onSecondaryContainer: Color(0xff141b2c),
        tertiary: Color(0xff625648),
        onTertiary: Color(0xffffffff),
        tertiaryContainer: Color(0xfffff7ee),
        onTertiaryContainer: Color(0xff0b1b36),
        error: Color(0xffba1a1a),
        onError: Color(0xffffffff),
        errorContainer: Color(0xffffdad6),
        onErrorContainer: Color(0xff410002),
        background: Color(0xfff5f7fc),
        onBackground: Color(0xff1a1c1e),
        surface: Color(0xfff8f4ee),
        onSurface: Color(0xff1a1c1e),
        surfaceVariant: Color(0xffd7dfe8),
        onSurfaceVariant: Color(0xff42474e),
        outline: Color(0xff72787e),
        outlineVariant: Color(0xffc2c7ce),
        shadow: Color(0xff000000),
        scrim: Color(0xff000000),
        inverseSurface: Color(0xff2d3135),
        onInverseSurface: Color(0xfff0f0f4),
        inversePrimary: Color(0xfffff0db),
        surfaceTint: Color(0xff625648),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.black12,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      )
    ),
  );
}
