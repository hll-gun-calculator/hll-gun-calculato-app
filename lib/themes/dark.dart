import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/index.dart';

class DarkTheme extends AppBaseThemeItem {
  @override
  init() {}

  @override
  changeSystem() {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
      statusBarBrightness: Brightness.light,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  @override
  get d => data;

  @override
  static dynamic data = AppThemeItem(
    name: "dark",
    isDefault: false,
    themeData: ThemeData.dark(useMaterial3: true).copyWith(
        primaryColor: Colors.black,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xffafc6ff),
          onPrimary: Color(0xff002d6d),
          primaryContainer: Color(0xff17448f),
          onPrimaryContainer: Color(0xffd9e2ff),
          secondary: Color(0xffb8c8da),
          onSecondary: Color(0xff23323f),
          secondaryContainer: Color(0xff394857),
          onSecondaryContainer: Color(0xffd4e4f6),
          tertiary: Color(0xffb8c6ea),
          onTertiary: Color(0xff22304c),
          tertiaryContainer: Color(0xff394764),
          onTertiaryContainer: Color(0xffd8e2ff),
          error: Color(0xffffb4ab),
          onError: Color(0xff690005),
          errorContainer: Color(0xff93000a),
          onErrorContainer: Color(0xffffb4ab),
          background: Color(0xff22232a),
          onBackground: Color(0xffe3e2e6),
          surface: Color(0xff22232a),
          onSurface: Color(0xffe3e2e6),
          surfaceVariant: Color(0xff494c57),
          onSurfaceVariant: Color(0xffc5c6d0),
          outline: Color(0xff8f9099),
          outlineVariant: Color(0xff44464f),
          shadow: Color(0xff000000),
          scrim: Color(0xff000000),
          inverseSurface: Color(0xffe0e0e7),
          onInverseSurface: Color(0xff303034),
          inversePrimary: Color(0xff355ca8),
          surfaceTint: Color(0xffafc6ff),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        )),
  );
}
