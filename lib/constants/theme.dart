import '../data/Theme.dart';
import '../themes/dark.dart';
import '../themes/lightnes.dart';

// ignore: constant_identifier_names
const String ThemeDefault = "lightnes";

// ignore: non_constant_identifier_names
Map<String, AppBaseThemeItem>? ThemeList = {
  "dark": DarkTheme(),
  "lightnes": LightnesTheme(),
};
