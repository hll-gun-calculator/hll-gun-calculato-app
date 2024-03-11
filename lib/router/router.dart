import 'package:fluro/fluro.dart';
import 'package:hll_gun_calculator/pages/calculating_function_create/index.dart';
import 'package:hll_gun_calculator/pages/index/map.dart';

// S Pages
import '../pages/map/index.dart';
import '/pages/setting/langage.dart';
import '/pages/license/index.dart';
import '/pages/collect/collect.dart';
import '/pages/setting/index.dart';
import '/pages/setting/theme.dart';
import '/pages/history/computing_history.dart';
import '/pages/setting/version.dart';
import '/pages/splash.dart';
import '/pages/index/home.dart';
import '/pages/setting/calculating_function_config.dart';
// E Pages

class Routes {
  static FluroRouter router = FluroRouter();
  static List? routerList = [
    {
      "url": '/',
      "item": (context, params) {
        return const MyHomePage();
      }
    },
    {
      "url": '/splash',
      "item": (context, params) {
        return const SplashPage();
      }
    },
    {
      "url": '/license',
      "item": (context, params) {
        return const LicensePage();
      }
    },
    {
      "url": '/language',
      "item": (context, params) {
        return const LanguagePage();
      }
    },
    {
      "url": '/collect',
      "item": (context, params) {
        return const CollectPage();
      }
    },
    {
      "url": '/theme',
      "item": (context, params) {
        return const ThemePage();
      }
    },
    {
      "url": '/setting/mapPackage',
      "item": (context, params) {
        return const MapPackagePage();
      }
    },
    {
      "url": '/setting/',
      "item": (context, params) {
        return const SettingPage();
      }
    },
    {
      "url": '/setting/version',
      "item": (context, params) {
        return const VersionPage();
      }
    },
    {
      "url": "/calculatingFunctionCreate",
      "item": (context, params) {
        return const CalculatingFunctionCreatePage();
      }
    },
    {
      "url": "/calculatingFunctionConfig",
      "item": (context, params) {
        return const CalculatingFunctionPage();
      }
    },
    {
      "url": "/computingHistoryPage",
      "item": (context, params) {
        return const ComputingHistoryPage();
      }
    }
  ];

  static void configureRoutes(FluroRouter router) {
    for (var i in routerList!) {
      router.define(
        i["url"],
        handler: Handler(
          handlerFunc: (context, Map<String, dynamic> params) {
            return i["item"](context, params);
          },
        ),
      );
    }

    Routes.router = router;
  }
}
